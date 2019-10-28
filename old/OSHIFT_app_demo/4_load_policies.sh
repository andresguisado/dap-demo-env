#!/bin/bash
set -eou pipefail

. ../utils.sh

announce "Initializing Conjur authorization policies..."

sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" \
    ./policy/templates/project-authn-defs.template.yml |
  sed -e "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" \
  > ./policy/project-authn-defs.yml

sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" \
     ./policy/templates/cluster-authn-defs.template.yml \
   > ./policy/cluster-authn-defs.yml

sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" \
    ./policy/templates/app-identity-defs.template.yml |
  sed -e "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" \
  > ./policy/app-identity-defs.yml

sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" \
    ./policy/templates/resource-access-grants.template.yml |
  sed -e "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" \
  > ./policy/resource-access-grants.yml

cat ./policy/templates/k8s-secrets.yml \
 > ./policy/k8s-secrets.yml

# copy policy directory contents to cli
docker cp ./policy conjur-cli:/policy

docker exec -it conjur-cli conjur authn login -u admin -p $CONJUR_ADMIN_PASSWORD

POLICY_FILE_LIST="
policy/project-authn-defs.yml
policy/cluster-authn-defs.yml
policy/app-identity-defs.yml
policy/k8s-secrets.yml
policy/resource-access-grants.yml
"
for i in $POLICY_FILE_LIST; do
        echo "Loading policy file: $i"
        docker exec conjur-cli conjur policy load root "/policy/$i"
done

# create initial value for variables
docker exec conjur-cli conjur variable values add k8s-secrets/db-username the-db-username
docker exec conjur-cli conjur variable values add k8s-secrets/db-password $(openssl rand -hex 12)
docker exec conjur-cli conjur variable values add k8s-secrets/app-username the-app-username
docker exec conjur-cli conjur variable values add k8s-secrets/app-apikey $(openssl rand -hex 12)

echo "Conjur policies loaded."

# Create the random database password
password=$(openssl rand -hex 12)

# Set DB password in Kubernetes manifests
# NOTE: generated files are prefixed with the test app namespace to allow for parallel CI

pushd kubernetes
  sed "s#{{ TEST_APP_DB_PASSWORD }}#$password#g" ./postgres.template.yml > ./tmp.${TEST_APP_NAMESPACE_NAME}.postgres.yml
  sed "s#{{ TEST_APP_DB_PASSWORD }}#$password#g" ./mysql.template.yml > ./tmp.${TEST_APP_NAMESPACE_NAME}.mysql.yml
popd

# Set DB password in OC manifests
# NOTE: generated files are prefixed with the test app namespace to allow for parallel CI
pushd openshift
  sed "s#{{ TEST_APP_DB_PASSWORD }}#$password#g" ./postgres.template.yml > ./tmp.${TEST_APP_NAMESPACE_NAME}.postgres.yml
  sed "s#{{ TEST_APP_DB_PASSWORD }}#$password#g" ./mysql.template.yml > ./tmp.${TEST_APP_NAMESPACE_NAME}.mysql.yml
popd
