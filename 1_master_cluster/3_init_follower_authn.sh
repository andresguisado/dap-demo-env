#!/bin/bash 
set -eou pipefail

. ../utils.sh

if [ $PLATFORM = 'kubernetes' ]; then
    cli=kubectl
elif [ $PLATFORM = 'openshift' ]; then
    cli=oc
else
  echo "$PLATFORM is not a supported platform"
  exit 1
fi

main() {
 load_policies
 initialize_ca
# apply_manifest
# initialize_variables
# initialize_config_map
}

###################################
load_policies() {
  announce "Initializing Conjur authorization policies..."

  sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" \
     ./policy/templates/cluster-authn-defs.template.yml |
    sed -e "s#{{ CONJUR_NAMESPACE_NAME }}#$CONJUR_NAMESPACE_NAME#g" |
    sed -e "s#{{ CONJUR_SERVICEACCOUNT_NAME }}#$CONJUR_SERVICEACCOUNT_NAME#g" \
    > ./policy/cluster-authn-defs.yml

  sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" \
    ./policy/templates/seed-service.template.yml |
    sed -e "s#{{ CONJUR_NAMESPACE_NAME }}#$CONJUR_NAMESPACE_NAME#g" |
    sed -e "s#{{ CONJUR_SERVICEACCOUNT_NAME }}#$CONJUR_SERVICEACCOUNT_NAME#g" \
    > ./policy/seed-service.yml

  # copy policy directory contents to cli
  docker cp ./policy conjur-cli:/policy

  docker exec -it conjur-cli conjur authn login -u admin -p $CONJUR_ADMIN_PASSWORD

  POLICY_FILE_LIST="
  policy/cluster-authn-defs.yml
  policy/seed-service.yml
  "
  for i in $POLICY_FILE_LIST; do
        echo "Loading policy file: $i"
        docker exec conjur-cli conjur policy load root "/policy/$i"
  done

  echo "Conjur policies loaded."
}

###################################
apply_manifest() {
  echo "Applying manifest in cluster..."

  if [[ $PLATFORM == openshift ]]; then
    $cli login -u $OSHIFT_CLUSTER_ADMIN_USERNAME
  fi

  sed -e "s#{{ CONJUR_NAMESPACE_NAME }}#$CONJUR_NAMESPACE_NAME#g" \
     ./manifests/conjur-follower-authn.template.yaml \
    > ./manifests/conjur-follower-authn.yaml
  $cli apply -f ./manifests/conjur-follower-authn.yaml

  echo "Manifest applied."
}

###################################
initialize_variables() {
  echo "Initializing variables..."

  TOKEN_SECRET_NAME="$($cli get secrets -n $CONJUR_NAMESPACE_NAME \
    | grep 'conjur.*service-account-token' \
    | head -n1 \
    | awk '{print $1}')"

  docker exec -it conjur-cli conjur variable values add \
    conjur/authn-k8s/$AUTHENTICATOR_ID/kubernetes/ca-cert \
    "$($cli get secret -n $CONJUR_NAMESPACE_NAME $TOKEN_SECRET_NAME -o json \
      | jq -r '.data["ca.crt"]' \
      | base64 -D)"

  docker exec -it conjur-cli conjur variable values add \
    conjur/authn-k8s/$AUTHENTICATOR_ID/kubernetes/service-account-token \
    "$($cli get secret -n $CONJUR_NAMESPACE_NAME $TOKEN_SECRET_NAME -o json \
      | jq -r .data.token \
      | base64 -D)"

  docker exec -it conjur-cli conjur variable values add \
    conjur/authn-k8s/$AUTHENTICATOR_ID/kubernetes/api-url \
    "$($cli config view --minify -o json \
      | jq -r '.clusters[0].cluster.server')"

  echo "Variables initialized."
}

###################################
initialize_ca() {
  echo "Initializing CA in Conjur Master..."

  docker exec $CONJUR_MASTER_CONTAINER_NAME \
    chpst -u conjur conjur-plugin-service possum \
      rake authn_k8s:ca_init["conjur/authn-k8s/$AUTHENTICATOR_ID"]

  docker exec $CONJUR_MASTER_CONTAINER_NAME bash -c \
    'echo CONJUR_AUTHENTICATORS=\"authn,authn-k8s/docs-$AUTHENTICATOR_ID\" >> \
      /opt/conjur/etc/conjur.conf && \
        sv restart conjur'

  echo "CA initialized."
}

initialize_config_map() {
  echo "Storing Conjur cert in config map for cluster apps to use."

  $cli delete --ignore-not-found=true -n default configmap $CONJUR_CONFIG_MAP

  # Store the Conjur cert in a ConfigMap.
  $cli create configmap -n default $CONJUR_CONFIG_MAP --from-file=ssl-certificate=<(cat "$CONJUR_CERT_FILE")

  echo "Conjur cert stored."
}

main "$@"
