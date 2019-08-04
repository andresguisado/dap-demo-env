#!/bin/bash
set -euo pipefail

source ./utils.sh

if [ $PLATFORM = 'openshift' ]; then
    docker login -u _ -p $(oc whoami -t) $DOCKER_REGISTRY_PATH
fi

announce "Building and pushing test app images."

# Tag images with cluster registry & namespace and push (unless minikube)
authenticator_client_tag=$(platform_image conjur-authn-k8s-client)
docker tag $AUTHENTICATOR_CLIENT_IMAGE $authenticator_client_tag
if ! is_minienv; then
  docker push $authenticator_client_tag
fi

secretless_broker_tag=$(platform_image secretless-broker)
docker tag $SECRETLESS_BROKER_IMAGE $secretless_broker_tag
if ! is_minienv; then
  docker push $secretless_broker_tag
fi

# entries in array correspond to names of directories under ./build/
readonly APPS=(
  "appserver"
  "webserver"
  "secretless"
  "pgsql"
  "mysql"
  "nginx-ocp"
)

for app_name in "${APPS[@]}"; do
  pushd ./build/$app_name
    if $CONNECTED; then
      ./build.sh
    fi

    test_app_image=$(platform_image "$app_name")
    docker tag $app_name:latest $test_app_image
    if ! is_minienv; then
      docker push $test_app_image
    fi
  popd
done
