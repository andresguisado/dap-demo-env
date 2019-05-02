#!/bin/bash -x
set -euo pipefail

. utils.sh

announce "Initializing Conjur certificate authority."

set_namespace $CONJUR_NAMESPACE_NAME

docker exec $CONJUR_MASTER_CONTAINER_NAME chpst -u conjur conjur-plugin-service possum rake authn_k8s:ca_init["conjur/authn-k8s/$AUTHENTICATOR_ID"]

echo "Certificate authority initialized."
