#!/bin/bash 
set -eu pipefail

source ./mtls-demo.conf

export CONJUR_AUTHN_API_KEY=$(docker exec -it conjur-cli conjur host rotate_api_key -h $MTLS_SERVER_LOGIN | tr -d '\r\n')

pushd ca >& /dev/null
./request_certificate $MTLS_SERVER_LOGIN $MTLS_SERVER_LOGIN/private-key $MTLS_SERVER_LOGIN/cert
popd ca >& /dev/null
