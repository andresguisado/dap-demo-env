#!/bin/bash 
set -eu pipefail

source ./mtls-demo.conf

export CONJUR_AUTHN_API_KEY=$(docker exec conjur-cli conjur host rotate_api_key -h $MTLS_CLIENT_LOGIN | tr -d '\r\n')

pushd ca >& /dev/null
./request_certificate $MTLS_CLIENT_LOGIN $MTLS_CLIENT_LOGIN/private-key $MTLS_CLIENT_LOGIN/cert
popd ca >& /dev/null
