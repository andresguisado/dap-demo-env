#!/bin/bash
source ../config/dap.config
source ../config/$PLATFORM.config

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
  if $CONNECTED; then
    build
  fi

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
  docker tag $LOCAL_SECRETLESS_APP_IMAGE $SECRETLESS_APP_IMAGE
  docker push $SECRETLESS_APP_IMAGE
  docker tag $LOCAL_SECRETLESS_BROKER_IMAGE $SECRETLESS_BROKER_IMAGE
  docker push $SECRETLESS_BROKER_IMAGE
  docker tag $LOCAL_DEMO_APP_IMAGE $DEMO_APP_IMAGE
  docker push $DEMO_APP_IMAGE
  docker tag $LOCAL_PGSQL_IMAGE $PGSQL_IMAGE
  docker push $PGSQL_IMAGE
  docker tag $LOCAL_MYSQL_IMAGE $MYSQL_IMAGE
  docker push $MYSQL_IMAGE
  docker tag $LOCAL_NGINX_IMAGE $NGINX_IMAGE
  docker push $NGINX_IMAGE
}

main "$@"
