#!/bin/bash
TP="${HTTPS_PROXY%:*}:3130"
exec env HTTPS_PROXY="$TP" ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o "ProxyCommand=python3 /home/hatch/workspace/scripts/ssh_proxy.py %h %p" -o ConnectTimeout=30 -o BatchMode=yes probook@100.103.223.52 "$@"
