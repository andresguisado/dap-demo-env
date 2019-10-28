#!/bin/bash
set -eou pipefail
docker-compose up -d server
docker-compose up -d client
docker exec -it client bash
