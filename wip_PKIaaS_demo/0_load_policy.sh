#!/bin/bash 
set -eu pipefail
docker cp ./policy/mutual_tls.yml conjur-cli:/policy
docker exec conjur-cli conjur authn login -u admin -p $CONJUR_ADMIN_PASSWORD
docker exec conjur-cli conjur policy load root /policy/mutual_tls.yml
