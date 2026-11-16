#!/bin/bash
# IQRS Hostinger SSH via Assad's laptop as jump host (Tailscale relay).
# Use when this VM's egress proxy refuses CONNECT tunnels to port 65002.
# Auth stays end-to-end with Muse's key (~/.ssh/id_ed25519, imported in
# hPanel as "Muse deploy key"); the laptop only relays the TCP stream.
# Usage: rssh-jump.sh '<remote command>'   (target host is fixed)
CFG="$(mktemp /tmp/iqrs-jumpcfg.XXXXXX)"
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
Host iqrsjump
  HostName 193.168.192.65
  Port 65002
  User u238632175
  IdentityFile /home/hatch/.ssh/id_ed25519
  IdentitiesOnly yes
  ProxyJump lapjump
  UserKnownHostsFile /home/hatch/.ssh/known_hosts
  StrictHostKeyChecking accept-new
  ConnectTimeout 30
  BatchMode yes
EOF2
TP="${HTTPS_PROXY%:*}:3130"
exec env HTTPS_PROXY="$TP" ssh -F "$CFG" iqrsjump "$@"
