#!/bin/bash
# Postiz host (srv1322702) SSH via Assad's laptop as jump host (Tailscale relay).
# Use when this VM's egress proxy refuses/resets direct tunnels to the host.
# Auth stays end-to-end with Muse's key; the laptop only relays TCP.
# Usage: rssh-postiz-jump.sh '<remote command>'
CFG="$(mktemp /tmp/postiz-jumpcfg.XXXXXX)"
trap 'rm -f "$CFG"' EXIT
cat > "$CFG" <<'EOF2'
Host lapjump
  HostName 100.103.223.52
  User probook
  IdentityFile /home/hatch/.ssh/id_ed25519
  IdentitiesOnly yes
  ProxyCommand python3 /home/hatch/workspace/scripts/ssh_proxy.py %h %p
  UserKnownHostsFile /home/hatch/.ssh/known_hosts
  StrictHostKeyChecking accept-new
  ConnectTimeout 30
  BatchMode yes
Host postizjump
  HostName 76.13.176.187
  Port 22
  User root
  IdentityFile /home/hatch/.ssh/id_ed25519
  IdentitiesOnly yes
  ProxyJump lapjump
  UserKnownHostsFile /home/hatch/.ssh/known_hosts
  StrictHostKeyChecking accept-new
  ConnectTimeout 30
  BatchMode yes
EOF2
TP="${HTTPS_PROXY%:*}:3130"
exec env HTTPS_PROXY="$TP" ssh -F "$CFG" postizjump "$@"
