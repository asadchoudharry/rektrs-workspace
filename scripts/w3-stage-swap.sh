#!/bin/bash
TAG=ghcr.io/asadchoudharry/postiz-app:next16-b79fc9f7
docker pull $TAG
docker tag $TAG rektrs/postiz:next16-b79fc9f7
sed -i 's|rektrs/postiz:next16-ee9c3021|rektrs/postiz:next16-b79fc9f7|' /root/postiz-staging/docker-compose.yml
grep -m1 'image:' /root/postiz-staging/docker-compose.yml
cd /root/postiz-staging && docker compose up -d postiz-app
sleep 3
docker inspect -f '{{.Config.Image}}' postiz-staging-postiz-app-1
echo W3-STAGE-SWAP-DONE
