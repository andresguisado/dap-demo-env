#!/bin/bash
set -euo pipefail

docker run -d \
    --name sf \
    --entrypoint sh \
    cyberark/dap-seedfetcher:latest \
    -c "sleep 10"
docker cp sf:/usr/bin/start-follower.sh ./start-follower.patched
docker stop sf > /dev/null && docker rm sf > /dev/null & 
ex -s -c '4i|# if not set already, set CONJUR_MASTER_PORT to 443' -c x start-follower.patched
ex -s -c '5i|CONJUR_MASTER_PORT=${CONJUR_MASTER_PORT-443}' -c x start-follower.patched
ex -s -c '6i| ' -c x start-follower.patched
sed '/evoke configure/ s/$/ -p $CONJUR_MASTER_PORT/' start-follower.patched > start-follower.sh
docker build -t dap-seedfetcher:patched .
rm -f start-follower.*
