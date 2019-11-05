#!/bin/bash
source ../config/dap.config
source ../config/$PLATFORM.config

# Tags local app image and authenticator client and pushes to registry.
# Registry image names are:
#   - $TEST_APP_IMAGE
#   - $AUTHENTICATOR_CLIENT_IMAGE
# defined in the $PLATFORM.config file and referenced in deployment manifests.

LOCAL_TEST_APP_IMAGE=test-app:latest 
LOCAL_AUTHENTICATOR_CLIENT_IMAGE=cyberark/conjur-authn-k8s-client:latest 

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
  docker tag $LOCAL_TEST_APP_IMAGE_NAME $TEST_APP_IMAGE
  docker push $TEST_APP_IMAGE
  docker tag $LOCAL_AUTHENTICATOR_CLIENT_IMAGE $AUTHENTICATOR_CLIENT_IMAGE
  docker push $AUTHENTICATOR_CLIENT_IMAGE
}

main "$@"
