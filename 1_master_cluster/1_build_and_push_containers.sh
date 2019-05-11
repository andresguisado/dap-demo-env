#!/bin/bash 
set -eou pipefail

. ../utils.sh

oshift="${OSHIFT_CONJUR_ADMIN:-unset}"
if [[ $oshift != unset ]]; then
  oc login -u $OSHIFT_CONJUR_ADMIN
  set_project $CONJUR_NAMESPACE_NAME
  echo $(oc whoami -t) | docker login -u _ --password-stdin $DOCKER_REGISTRY_PATH
fi

main() {
  push_conjur_appliance
  push_cli
  if [[ ! $CONJUR_SIMPLE_CLUSTER ]]; then
	push_haproxy
  fi
  echo "Docker images pushed."
}

####################
push_conjur_appliance() {
  announce "Building and pushing conjur-appliance image."

  if [[ $CONNECTED == true ]]; then
    pushd build/conjur_server
      ./build.sh
    popd
  else
    docker tag $CONJUR_APPLIANCE_IMAGE conjur-appliance:$CONJUR_NAMESPACE_NAME
  fi

  if [[ $oshift != unset ]]; then
    docker_tag_and_push $CONJUR_NAMESPACE_NAME "conjur-appliance"
  fi
}

####################
push_haproxy() {
  announce "Building and pushing haproxy image."

  if [[ $CONNECTED == true ]]; then
    pushd build/haproxy
      ./build.sh
    popd
  fi
}

####################
push_cli() {
  announce "Pulling and pushing Conjur CLI image."

#  if [[ $CONNECTED == true ]]; then
#    docker pull $CLI_IMAGE_NAME
#  fi
  docker tag $CLI_IMAGE_NAME conjur-cli:$CONJUR_NAMESPACE_NAME

  if [[ $oshift != unset ]]; then
    docker_tag_and_push $CONJUR_NAMESPACE_NAME "conjur-cli"
  fi
}

main $@
