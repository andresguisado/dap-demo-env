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
#   - $MSSQLSERVER_IMAGE
#   - $NGINX_IMAGE
#
# All are defined in the $PLATFORM.k8s file and referenced in deployment manifests.

LOCAL_SECRETLESS_APP_IMAGE=secretless:latest
LOCAL_SECRETLESS_BROKER_IMAGE=secretless-broker:latest
LOCAL_DEMO_APP_IMAGE=cyberark/demo-app:latest
LOCAL_PGSQL_IMAGE=pgsql:latest
LOCAL_MYSQL_IMAGE=mysql:latest
LOCAL_MSSQLSERVER_IMAGE=mssqlserver:latest
LOCAL_NGINX_IMAGE=nginx-secretless:latest

main() {
  ./precheck_secretless.sh

  login_as $DEVELOPER_USERNAME
  if $CONNECTED; then
    build_images
  fi
  registry_login
  tag_and_push
}

###################################
build_images() {
  # entries in array correspond to names of directories under ./build/
  readonly APPS=(
    "secretless"
    "pgsql"
    "mysql"
    "mssqlserver"
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
  docker tag $LOCAL_MSSQLSERVER_IMAGE $MSSQLSERVER_IMAGE
  docker tag $LOCAL_NGINX_IMAGE $NGINX_IMAGE

  if ! $MINIKUBE; then
    docker push $SECRETLESS_APP_IMAGE
    docker push $SECRETLESS_BROKER_IMAGE
    docker push $DEMO_APP_IMAGE
    docker push $PGSQL_IMAGE
    docker push $MYSQL_IMAGE
    docker push $MSSQLSERVER_IMAGE
    docker push $NGINX_IMAGE
  fi
}

main "$@"
