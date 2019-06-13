#!/bin/bash
set -eou pipefail

. ../utils.sh

announce "Initializing Conjur authorization policies..."

sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" \
    ./policy/templates/service-accounts.template.yml |
  sed -e "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" \
  > ./policy/service-accounts.yml

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
policy/service-accounts.yml
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
