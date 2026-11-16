#!/bin/bash
# IQRS Hostinger SSH wrapper with the fixed port 65002 baked in, for use
# as an rsync -e transport (the -e string cannot carry spaces/options).
exec ssh -i /home/hatch/.ssh/id_ed25519 -o IdentitiesOnly=yes -o UserKnownHostsFile=/home/hatch/.ssh/known_hosts -o StrictHostKeyChecking=accept-new -o "ProxyCommand=python3 /home/hatch/workspace/scripts/ssh_proxy.py %h %p" -o ConnectTimeout=30 -p 65002 "$@"
