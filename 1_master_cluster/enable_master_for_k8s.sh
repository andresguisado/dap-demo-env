#!/bin/bash

source ../config/dap.config
source ../config/$PLATFORM.config

# This script enables authn-k8s in a running DAP Master.
# It's useful for the case where a DAP Master were stood up w/o using the 1_docker_master script.
# It must be run on the host where the DAP Master is running.
# It does NOT need to use kubectl or oc.

NEW_AUTHENTICATOR="authn-k8s/$AUTHENTICATOR_ID"

#################
main() {
  load_follower_authn_policies
  initialize_ca
  add_new_authenticator
  wait_till_master_is_responsive
}

###################################
load_follower_authn_policies() {
  echo "Initializing Conjur authorization policies..."

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

  POLICY_FILE_LIST="
  ./policy/cluster-authn-defs.yml
  ./policy/seed-service.yml
  "
  for i in $POLICY_FILE_LIST; do
        echo "Loading policy file: $i"
        load_policy_REST.sh root "$i"
  done

  echo "Conjur policies loaded."
}

############################
initialize_ca() {
  echo "Initializing CA in Conjur Master..."
  docker exec $CONJUR_MASTER_CONTAINER_NAME \
    chpst -u conjur conjur-plugin-service possum \
      rake authn_k8s:ca_init["conjur/authn-k8s/$AUTHENTICATOR_ID"]
  echo "CA initialized."
}

############################
add_new_authenticator() {
  echo "Updating list of whitelisted authenticators..."
					# get current authenticators in conjur.conf
  docker exec $CONJUR_MASTER_CONTAINER_NAME cat /opt/conjur/etc/conjur.conf > temp.conf
  authn_str=$(grep -i AUTHENTICATORS temp.conf)

  if [[ "$authn_str" == "" ]]; then	# If no authenticators specified...
					# add authenticators to conjur.conf
    echo "CONJUR_AUTHENTICATORS=\"${CONJUR_AUTHENTICATORS}\"" >> temp.conf
    docker exec -i $CONJUR_MASTER_CONTAINER_NAME dd of=/opt/conjur/etc/conjur.conf < temp.conf
  else
					# else replace line in conjur.conf
    docker exec $CONJUR_MASTER_CONTAINER_NAME \
		sed -i.bak "s#CONJUR_AUTHENTICATORS=.*#CONJUR_AUTHENTICATORS=\"${CONJUR_AUTHENTICATORS}\"#" \
		/opt/conjur/etc/conjur.conf
  fi
  rm -f temp.conf
  docker exec $CONJUR_MASTER_CONTAINER_NAME sv restart conjur

  echo "Authenticators updated."
}

############################
wait_till_master_is_responsive() {
  set +e
  master_is_healthy=""
  while [[ "$master_is_healthy" == "" ]]; do
    sleep 2
    master_is_healthy=$(curl -k $CONJUR_APPLIANCE_URL/health | grep "ok" | tail -1 | grep "true")
  done
  set -e
}

main "$@"
