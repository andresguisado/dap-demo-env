#!/bin/bash
source ../config/dap.config

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
LOCAL_SECRETLESS_BROKER_IMAGE=cyberark/secretless-broker:latest
LOCAL_DEMO_APP_IMAGE=cyberark/demo-app:latest
LOCAL_PGSQL_IMAGE=pgsql:latest
LOCAL_MYSQL_IMAGE=mysql:latest
LOCAL_NGINX_IMAGE=nginx-secretless:latest

main() {
  ./precheck_secretless.sh

  if $CONNECTED; then
    build
  fi

  login_as $CLUSTER_ADMIN_USERNAME
  create_test_app_namespace
  configure_rbac
  login_as $DEVELOPER_USERNAME
  registry_login
  tag_and_push
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

###########################
# Login with user parameter
#
login_as() {
  local user=$1
  if [[ "$PLATFORM" == "openshift" ]]; then
    oc login -u $user
  fi
}

############################
create_test_app_namespace() {
  announce "Creating Test App namespace."
  set_namespace default
  if has_namespace "$TEST_APP_NAMESPACE_NAME"; then
    echo "Namespace '$TEST_APP_NAMESPACE_NAME' exists, not going to create it."
  else
    echo "Creating '$TEST_APP_NAMESPACE_NAME' namespace."
    $CLI create namespace $TEST_APP_NAMESPACE_NAME
  fi
  set_namespace $TEST_APP_NAMESPACE_NAME
}

###################################
configure_rbac() {
  if [[ "$PLATFORM" != "openshift" ]]; then
    return
  fi

  echo "Configuring OpenShift developer permissions."
  oc adm policy add-role-to-user system:registry $DEVELOPER_USERNAME
  oc adm policy add-role-to-user system:image-builder $DEVELOPER_USERNAME
  oc adm policy add-role-to-user admin $DEVELOPER_USERNAME -n $TEST_APP_NAMESPACE_NAME
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
