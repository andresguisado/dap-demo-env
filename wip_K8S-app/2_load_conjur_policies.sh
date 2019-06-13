#!/bin/bash -x
set -euo pipefail

. utils.sh

announce "Generating Conjur policy."

pushd policy
  mkdir -p ./generated

  sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" ./templates/cluster-authn-svc-def.template.yml > ./generated/cluster-authn-svc.yml

  sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" ./templates/project-authn-def.template.yml |
    sed -e "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" > ./generated/project-authn.yml

  sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" ./templates/app-identity-def.template.yml |
    sed -e "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" > ./generated/app-identity.yml
popd

# Create the random database password
password=$(openssl rand -hex 12)

announce "Loading Conjur policy."

docker cp ./policy/. $CLI_CONTAINER_NAME:/policy

docker exec $CLI_CONTAINER_NAME \
    bash -c "
      CONJUR_ADMIN_PASSWORD=${CONJUR_ADMIN_PASSWORD} \
      DB_PASSWORD=${password} \
      TEST_APP_NAMESPACE_NAME=${TEST_APP_NAMESPACE_NAME} \
      CONJUR_VERSION=${CONJUR_VERSION} \
      /policy/load_policies.sh
    "

echo "Conjur policy loaded."

# Set DB password in DB schema
pushd pg
  sed -e "s#{{ TEST_APP_PG_PASSWORD }}#$password#g" ./schema.template.sql > ./schema.sql
popd

# Set DB password in OC deployment manifest
pushd openshift
  sed -e "s#{{ TEST_APP_PG_PASSWORD }}#$password#g" ./postgres.template.yml > ./postgres.yml
popd

announce "Added DB password value: $password"
