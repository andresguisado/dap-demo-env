#!/bin/bash 
set -eu

source ./mtls-demo.conf

main() {
  # nginx doesn't support environment vars in config file
  # get server TLS creds from Conjur to build into image
  docker exec conjur-cli conjur authn login -u admin -p $CONJUR_ADMIN_PASSWORD
  docker exec -it conjur-cli conjur variable value conjur/mutual-tls/ca/cert-chain > ./build/server/tls-ca-chain
  docker exec -it conjur-cli conjur variable value mutual-tls/server/private-key > ./build/server/tls-private-key
  docker exec -it conjur-cli conjur variable value mutual-tls/server/cert > ./build/server/tls-cert
  docker-compose build server
  rm ./build/server/tls*

  # Conjurize client so it can retrieve TLS creds dynamically
  create_id_files client $MTLS_CLIENT_LOGIN ./build/client
  docker-compose build client
  rm ./build/client/conjur*
}

create_id_files() {
# creates conjur* conjurization files in the target build directory 
  local CONT_ID=$1; shift
  local HOST_LOGIN=$1; shift
  local BUILD_DIR=$1; shift

  # Copy cert to build dir
  cp $CONJUR_CERT_FILE $BUILD_DIR

  # Get host API key
  docker exec -it conjur-cli bash -c "echo yes | conjur init -u $CONJUR_APPLIANCE_URL -a $CONJUR_ACCOUNT --force=true"
  docker exec -it conjur-cli conjur authn login -u admin -p $CONJUR_ADMIN_PASSWORD
  CONJUR_AUTHN_API_KEY=$(docker exec -it conjur-cli conjur host rotate_api_key --host $HOST_LOGIN)

  # Create identity files (AKA .netrc)
  echo "Generating $HOST_LOGIN identity file..."
  cat <<IDENTITY_EOF | tee $BUILD_DIR/conjur.identity
machine $CONJUR_APPLIANCE_URL/authn
  login host/$HOST_LOGIN
  password $CONJUR_AUTHN_API_KEY
IDENTITY_EOF

  # Create config file for Conjur service
  echo
  echo "Generating $HOST_LOGIN configuration file..."
  cat <<CONF_EOF | tee $BUILD_DIR/conjur.conf
---
appliance_url: $CONJUR_APPLIANCE_URL
account: $CONJUR_ACCOUNT
netrc_path: "/etc/conjur.identity"
cert_file: "/etc/conjur-$CONJUR_ACCOUNT.pem"
CONF_EOF
}

main "$@"
