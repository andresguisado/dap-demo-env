#!/bin/bash
source ../config/dap.config
source ../config/$PLATFORM.config

# Tags local appliance image and seed-fetcher image and pushes to registry.
# Registry image names are:
#   - $CONJUR_APPLIANCE_REG_IMAGE
#   - $SEED_FETCHER_IMAGE
# defined in the $PLATFORM.config file and referenced in deployment manifests.

LOCAL_CONJUR_APPLIANCE_IMAGE=$CONJUR_APPLIANCE_IMAGE
LOCAL_SEED_FETCHER_IMAGE=seed-fetcher:latest

main() {
  if $CONNECTED; then
    pushd build
      ./build.sh
    popd
  fi

  registry_login
  tag_and_push
}

###################################
registry_login() {
  if [[ "${PLATFORM}" = "openshift" ]]; then
    docker login -u _ -p $(oc whoami -t) $DOCKER_REGISTRY_URL
  else
    if ! [ "${DOCKER_EMAIL}" = "" ]; then
      $CLI delete --ignore-not-found secret dockerpullsecret
      $CLI create secret docker-registry dockerpullsecret \
           --docker-server=$DOCKER_REGISTRY_URL \
           --docker-username=$DOCKER_USERNAME \
           --docker-password=$DOCKER_PASSWORD \
           --docker-email=$DOCKER_EMAIL
    fi
  fi
}

###################################
tag_and_push() {
  # tag & push local K8S_followers images to registry
  docker tag $LOCAL_CONJUR_APPLIANCE_IMAGE $CONJUR_APPLIANCE_REG_IMAGE
  docker push $CONJUR_APPLIANCE_REG_IMAGE
  docker tag $LOCAL_SEED_FETCHER_IMAGE $SEED_FETCHER_IMAGE
  docker push $SEED_FETCHER_IMAGE
}

main "$@"
