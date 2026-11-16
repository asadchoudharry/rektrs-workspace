# Sendqon (Zender 5.0.4) — app image
# Multi-stage: Node 22 builds the frontend assets, PHP 8.4-FPM + nginx serves.
# Build context: the Zender app source tree (vendor/ ships inside it).
# Mirrors the vendor autosetup layout: WORKDIR /var/www/zender.

# ─── Stage 1: frontend assets ────────────────────────────────────────────────
FROM node:22-bookworm-slim AS assets
WORKDIR /build
COPY . .
RUN npm ci && npm run build && rm -rf node_modules

# ─── Stage 2: runtime ────────────────────────────────────────────────────────
FROM php:8.4-fpm-bookworm

# System packages: nginx + supervisor run the container's processes,
# ffmpeg remuxes browser voice notes (WebM -> Ogg/Opus) like the autosetup.
# The -dev packages are build deps for the PHP extensions below.
RUN apt-get update && apt-get install -y --no-install-recommends \
        nginx supervisor ffmpeg unzip git \
        libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
        libicu-dev libzip-dev libxml2-dev libonig-dev libcurl4-openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        pdo_mysql mysqli mbstring xml curl zip bcmath gd intl opcache pcntl sockets \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer (official image, multi-arch)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/zender

# Full app tree from the assets stage (source + built public/ assets).
COPY --from=assets /build /var/www/zender

# PHP limits — autosetup pool parity (Meta's 100MB document limit drives 128M).
RUN printf '%s\n' \
        'upload_max_filesize = 128M' \
        'post_max_size = 128M' \
        'memory_limit = 512M' \
        'max_execution_time = 120' \
        > /usr/local/etc/php/conf.d/zender.ini

# Vendor ships complete in the source tree: verify it, only fall back to a
# network composer install if the shipped tree is broken.
RUN if php -r "require 'vendor/autoload.php';" 2>/dev/null; then \
        echo 'vendor/ verified: autoload OK, skipping composer install'; \
    else \
        echo 'vendor/ autoload FAILED, running composer install'; \
        composer install --no-dev --optimize-autoloader --no-interaction; \
    fi

# nginx site: front-controller pattern, only index.php executes
# (simplified faithful version of the autosetup vhost; Reverb proxy paths are
# NOT here — the browser reaches Reverb through the host Caddy, per design).
RUN rm -f /etc/nginx/sites-enabled/default && cat > /etc/nginx/sites-available/zender <<'EOF'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/zender/public;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    client_max_body_size 128M;
    index index.php;
    charset utf-8;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 5;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/javascript application/javascript application/json image/svg+xml application/xml;

    location ^~ /build/assets/ {
        try_files $uri =404;
        expires 1y;
        access_log off;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location = /index.php {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_buffer_size 32k;
        fastcgi_buffers 16 16k;
        fastcgi_read_timeout 120s;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ \.php$ { return 404; }

    location ^~ /storage/ {
        try_files $uri /index.php?$query_string;
        location ~ \.(php|phtml|phar|pht|phps|cgi|pl|py|sh)$ { return 404; }
        location ~ /\. { deny all; }
    }

    location ~ /\.(?!well-known).* { deny all; }
}
EOF
RUN ln -sf /etc/nginx/sites-available/zender /etc/nginx/sites-enabled/zender

# Supervisor: nginx + php-fpm in this container (reverb/queue/scheduler are
# separate services in the compose stack, same image, own commands).
RUN cat > /etc/supervisor/conf.d/sendqon.conf <<'EOF'
[supervisord]
nodaemon=true
user=root

[program:php-fpm]
command=php-fpm -F
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:nginx]
command=nginx -g 'daemon off;'
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R ug+rwX storage bootstrap/cache

# Writability the web installer checks (and the runtime needs): the app root
# directory entry itself, public/ and database/ owned by www-data. The
# entrypoint re-applies the same fixes at every container start.
RUN chown www-data:www-data /var/www/zender \
    && chown -R www-data:www-data public database \
    && chmod 775 public database

# Entrypoint: materializes .env from the container env when missing (a
# recreate would otherwise lose the installer's hand-written .env — only
# storage/ is a volume) and re-applies the writability fixes, then execs the
# service command. Ships in the build context root.
COPY --from=assets /build/docker-entrypoint.sh /usr/local/bin/sendqon-entrypoint.sh
RUN chmod +x /usr/local/bin/sendqon-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/sendqon-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/sendqon.conf"]
