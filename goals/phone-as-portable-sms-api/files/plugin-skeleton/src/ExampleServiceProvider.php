<?php

namespace App\Plugins\Tools\Example\Runtime;

use Illuminate\Support\ServiceProvider;

/**
 * Runtime provider stub. PluginServiceProvider ise har boot par
 * register karta hai (runtime types ke liye) — is liye yahan ka
 * code plugin ke INACTIVE honay par bhi chalta hai: routes/middleware
 * ko active-check se gate karo (Legacy Importer ka
 * EnsureLegacyImporterActive middleware precedent), ya core ke
 * apne access gates par chhor do.
 */
final class ExampleServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->loadMigrationsFrom(dirname(__DIR__).'/migrations');
    }

    public function boot(): void
    {
        $this->app->booted(function () {
            $routes = __DIR__.'/Routes/web.php';
            if (is_file($routes)) {
                require $routes;
                $this->app->make('router')->getRoutes()->refreshNameLookups();
            }
        });
    }
}
