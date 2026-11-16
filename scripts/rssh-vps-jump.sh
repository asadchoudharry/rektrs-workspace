#!/bin/bash
# Operqon VPS SSH via Assad's laptop as jump host (Tailscale relay).
# Use when this VM's egress proxy refuses CONNECT tunnels to the VPS.
# Owner-directed 2026-11-11 (Assad, ERP chat: "Tumhara bhi agar ssh Ka
# masla ho to mery laptop say connect Ker lena"). Auth stays end-to-end
# with Muse's key (~/.ssh/id_ed25519); the laptop only relays TCP.
# Usage: rssh-vps-jump.sh '<remote command>'   (target host is fixed)
CFG="$(mktemp /tmp/vps-jumpcfg.XXXXXX)"
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
Host vpsjump
  HostName 72.61.214.64
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
exec env HTTPS_PROXY="$TP" ssh -F "$CFG" vpsjump "$@"
