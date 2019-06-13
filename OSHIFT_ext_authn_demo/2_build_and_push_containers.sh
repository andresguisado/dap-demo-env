#!/bin/bash
set -euo pipefail

. utils.sh

if [ $PLATFORM = 'openshift' ]; then
    docker login -u _ -p $(oc whoami -t) $DOCKER_REGISTRY_PATH
fi

announce "Building and pushing test app images."

authenticator_client_image=$(platform_image conjur-authn-k8s-client)
docker tag $AUTHENTICATOR_CLIENT_IMAGE $authenticator_client_image
if ! is_minienv; then
  docker push $authenticator_client_image
fi

readonly APPS=(
  "init"
  "sidecar"
)

pushd webapp
    ./build.sh

    for app_type in "${APPS[@]}"; do
      test_app_image=$(platform_image "test-$app_type-app")
      docker tag test-app:latest $test_app_image
      if ! is_minienv; then
        docker push $test_app_image
      fi
    done
popd

