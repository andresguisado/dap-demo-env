#!/bin/bash +e
source ../config/dap.config
source ../config/utils.sh

# Tags local images for Secretless demo and pushes them to registry.
#
# Registry image names are:
#   - $SECRETLESS_APP_IMAGE
#   - $SECRETLESS_BROKER_IMAGE
#   - $DEMO_APP_IMAGE
#   - $PGSQL_IMAGE
#   - $MYSQL_IMAGE
#   - $NGINX_IMAGE
#
# All are defined in the $PLATFORM.config file and referenced in deployment manifests.

LOCAL_SECRETLESS_APP_IMAGE=secretless:latest
LOCAL_SECRETLESS_BROKER_IMAGE=secretless-broker:latest
LOCAL_DEMO_APP_IMAGE=cyberark/demo-app:latest
LOCAL_PGSQL_IMAGE=pgsql:latest
LOCAL_MYSQL_IMAGE=mysql:latest
LOCAL_NGINX_IMAGE=nginx-secretless:latest

main() {
  login_as $CLUSTER_ADMIN_USERNAME
  apply_manifests

  login_as $DEVELOPER_USERNAME
  if $CONNECTED; then
    build
  fi
  registry_login
  tag_and_push
}

###################################
apply_manifests() {
  echo "Creating namespace & RBAC role bindings..."

  sed -e "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g"   \
     ./manifests/templates/dap-user-rbac.template.yaml           |
    sed -e "s#{{ CONJUR_NAMESPACE_NAME }}#$CONJUR_NAMESPACE_NAME#g" |
    sed -e "s#{{ DEVELOPER_USERNAME }}#$DEVELOPER_USERNAME#g" \
    > ./manifests/dap-user-rbac-$TEST_APP_NAMESPACE_NAME.yaml

  $CLI apply -f ./manifests/dap-user-rbac-$TEST_APP_NAMESPACE_NAME.yaml

  if $PLATFORM != openshift; then
    return
  fi

  # Stateful database pods need to be able to modify their internal state
  $CLI adm policy add-scc-to-user anyuid -z secretless-stateful-app -n $TEST_APP_NAMESPACE_NAME

  echo "User RBAC manifest applied."
}

###################################
build() {
  # entries in array correspond to names of directories under ./build/
  readonly APPS=(
    "secretless"
    "pgsql"
    "mysql"
    "nginx-secretless"
  )

  for app_name in "${APPS[@]}"; do
    if $CONNECTED; then
      pushd ./build/$app_name
        ./build.sh
      popd
    fi
  done
}

###################################
tag_and_push() {
set -x
  docker tag $LOCAL_SECRETLESS_APP_IMAGE $SECRETLESS_APP_IMAGE
  docker tag $LOCAL_SECRETLESS_BROKER_IMAGE $SECRETLESS_BROKER_IMAGE
  docker tag $LOCAL_DEMO_APP_IMAGE $DEMO_APP_IMAGE
  docker tag $LOCAL_PGSQL_IMAGE $PGSQL_IMAGE
  docker tag $LOCAL_MYSQL_IMAGE $MYSQL_IMAGE
  docker tag $LOCAL_NGINX_IMAGE $NGINX_IMAGE

  if ! $MINIKUBE; then
    docker push $SECRETLESS_APP_IMAGE
    docker push $SECRETLESS_BROKER_IMAGE
    docker push $DEMO_APP_IMAGE
    docker push $PGSQL_IMAGE
    docker push $MYSQL_IMAGE
    docker push $NGINX_IMAGE
  fi
}

main "$@"
