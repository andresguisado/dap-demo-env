#!/bin/bash 
set -eo pipefail

. utils.sh

#TEST_APP_DATABASE=mysql
TEST_APP_DATABASE=postgres

main() {
  announce "Deploying Secretless app for $TEST_APP_NAMESPACE_NAME."

  set_namespace $TEST_APP_NAMESPACE_NAME
  init_registry_creds
  init_connection_specs

  if is_minienv; then
    IMAGE_PULL_POLICY='Never'
  else
    IMAGE_PULL_POLICY='IfNotPresent'
  fi

  create_k8s_secrets

  deploy_database
  deploy_secretless_app
#  initialize_injector
}

###########################
init_registry_creds() {
  if [ $PLATFORM = 'kubernetes' ]; then
    if ! [ "${DOCKER_EMAIL}" = "" ]; then
      announce "Creating image pull secret."
    
      kubectl delete --ignore-not-found secret dockerpullsecret

      kubectl create secret docker-registry dockerpullsecret \
        --docker-server=$DOCKER_REGISTRY_URL \
        --docker-username=$DOCKER_USERNAME \
        --docker-password=$DOCKER_PASSWORD \
        --docker-email=$DOCKER_EMAIL
    fi
  elif [ $PLATFORM = 'openshift' ]; then
    announce "Creating image pull secret."
    
    $cli delete --ignore-not-found secrets dockerpullsecret
  
    $cli secrets new-dockercfg dockerpullsecret \
      --docker-server=${DOCKER_REGISTRY_PATH} \
      --docker-username=_ \
      --docker-password=$($cli whoami -t) \
      --docker-email=_
  
    $cli secrets add serviceaccount/default secrets/dockerpullsecret --for=pull    
  fi
}

###########################
init_connection_specs() {
#  secretless_app_image="cyberark/demo-app"
  secretless_app_image=$(platform_image secretless)
  secretless_broker_image=$(platform_image secretless-broker)
  authenticator_client_image=$(platform_image conjur-authn-k8s-client)

  conjur_appliance_url=https://conjur-follower.$CONJUR_NAMESPACE_NAME.svc.cluster.local/api
  conjur_authenticator_url=https://conjur-follower.$CONJUR_NAMESPACE_NAME.svc.cluster.local/api/authn-k8s/$AUTHENTICATOR_ID

  conjur_authn_login_prefix=host/conjur/authn-k8s/$AUTHENTICATOR_ID/apps/$TEST_APP_NAMESPACE_NAME/service_account
}

###########################
create_k8s_secrets() {

  $cli delete --ignore-not-found secret test-app-secret
  $cli create secret generic test-app-secret \
	--from-literal=secret-key=Can-You-Read-This-Secret?
}

###########################
deploy_database() {
  $cli delete --ignore-not-found \
     service/test-app-secretless-backend \
     statefulset/postgres-db \
     statefulset/mysql-db \
     secret/test-app-backend-certs
  ensure_env_database

  # Create the random database password
  DB_PASSWORD=$(openssl rand -hex 12)

  # Set DB DB_PASSWORD in Kubernetes manifests
  # NOTE: generated files are prefixed with the test app namespace to allow for parallel CI

  pushd kubernetes
    sed "s#{{ TEST_APP_DB_PASSWORD }}#$DB_PASSWORD#g" ./postgres.template.yml > ./tmp.${TEST_APP_NAMESPACE_NAME}.postgres.yml
    sed "s#{{ TEST_APP_DB_PASSWORD }}#$DB_PASSWORD#g" ./mysql.template.yml > ./tmp.${TEST_APP_NAMESPACE_NAME}.mysql.yml
popd

  # Set DB password in OC manifests
  # NOTE: generated files are prefixed with the test app namespace to allow for parallel CI
  pushd openshift
    sed "s#{{ TEST_APP_DB_PASSWORD }}#$DB_PASSWORD#g" ./postgres.template.yml > ./tmp.${TEST_APP_NAMESPACE_NAME}.postgres.yml
    sed "s#{{ TEST_APP_DB_PASSWORD }}#$DB_PASSWORD#g" ./mysql.template.yml > ./tmp.${TEST_APP_NAMESPACE_NAME}.mysql.yml
  popd


  case "${TEST_APP_DATABASE}" in

  postgres) #######################################
    echo "Create secrets for test app backend"
    $cli --namespace $TEST_APP_NAMESPACE_NAME \
      create secret generic \
      test-app-backend-certs \
      --from-file=server.crt=./etc/ca.pem \
      --from-file=server.key=./etc/ca-key.pem

    echo "Deploying test app backend"

    test_app_pg_docker_image=$(platform_image pgsql)

    sed "s#{{ TEST_APP_PG_DOCKER_IMAGE }}#$test_app_pg_docker_image#g" ./$PLATFORM/tmp.${TEST_APP_NAMESPACE_NAME}.postgres.yml |
      sed "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" |
      sed "s#{{ IMAGE_PULL_POLICY }}#$IMAGE_PULL_POLICY#g" |
      $cli create -f -

      wait_for_running_pod postgres-db-0
      sleep 5 # allow for db startup

      # HACK ALERT: turn on connect/disconnect logging - not elegant but conf file doesn't exist in image
      if [ $PLATFORM = openshift ]; then
        PG_CONF_FILE=/var/lib/pgsql/data/userdata/postgresql.conf
	PG_RUNUSER=""
	PG_DATA=/var/lib/pgsql/data/userdata
        PG_CTL=/opt/rh/rh-postgresql95/root/usr/bin/pg_ctl
      else
        PG_CONF_FILE=/var/lib/postgresql/data/postgresql.conf
	PG_RUNUSER="runuser -l postgres -c"
	PG_DATA=/var/lib/postgresql/data 
	PG_CTL=/usr/lib/postgresql/9.6/bin/pg_ctl
      fi

      $cli exec -it postgres-db-0 -- bash -c "sed -e 's#\#log_connections = off#log_connections = on#' -i $PG_CONF_FILE"
      $cli exec -it postgres-db-0 -- bash -c "sed -e 's#\#log_disconnections = off#log_disconnections = on#' -i $PG_CONF_FILE"
      $cli exec -it postgres-db-0 -- bash -c "$PG_RUNUSER PGDATA=$PG_DATA $PG_CTL reload"

      wait_for_running_pod postgres-db-0
    ;;

  mysql) #######################################
    echo "Deploying test app backend"

    test_app_mysql_docker_image="mysql/mysql-server:5.7"

    sed "s#{{ TEST_APP_DATABASE_DOCKER_IMAGE }}#$test_app_mysql_docker_image#g" ./$PLATFORM/tmp.${TEST_APP_NAMESPACE_NAME}.mysql.yml |
     sed "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" |
     sed "s#{{ IMAGE_PULL_POLICY }}#$IMAGE_PULL_POLICY#g" |
     $cli create -f -
    ;;

  esac

}

###########################
deploy_secretless_app() {
  $cli delete --ignore-not-found \
    deployment/test-app-secretless \
    service/test-app-secretless \
    serviceaccount/test-app-secretless \
    serviceaccount/k8s-secretless-broker \
    serviceaccount/ocp-secretless-broker \
    configmap/test-app-secretless-config

  if [[ "$PLATFORM" == "openshift" ]]; then
    oc delete --ignore-not-found \
      deploymentconfig/test-app-secretless \
      route/test-app-secretless
  fi

  $cli create configmap test-app-secretless-config \
    --from-file=etc/secretless.yml

  sleep 5

  ensure_env_database
  case "${TEST_APP_DATABASE}" in
  postgres)
    DB_PORT=5432
    DB_PROTOCOL=postgresql
    ;;
  mysql)
    DB_PORT=3306
    DB_PROTOCOL=mysql
    ;;
  esac

  DB_NAME=test_app
  DB_HOST=test-app-secretless-backend
  DB_ADDRESS="$DB_HOST:$DB_PORT/$DB_NAME"
  DB_USERNAME=test_app
  DB_SSLMODE=disable

  # Set connections values in Conjur
  ./var_value_add_REST.sh test-app-secretless-db/address $DB_ADDRESS
  ./var_value_add_REST.sh test-app-secretless-db/username $DB_USERNAME
  ./var_value_add_REST.sh test-app-secretless-db/password $DB_PASSWORD
  ./var_value_add_REST.sh test-app-secretless-db/sslmode $DB_SSLMODE
 
  sed "s#{{ CONJUR_VERSION }}#$CONJUR_VERSION#g" ./$PLATFORM/test-app-secretless.yml |
    sed "s#{{ SECRETLESS_BROKER_IMAGE }}#$secretless_broker_image#g" |
    sed "s#{{ SECRETLESS_APP_IMAGE }}#$secretless_app_image#g" |
    sed "s#{{ IMAGE_PULL_POLICY }}#$IMAGE_PULL_POLICY#g" |
    sed "s#{{ CONJUR_AUTHN_URL }}#$conjur_authenticator_url#g" |
    sed "s#{{ CONJUR_AUTHN_LOGIN_PREFIX }}#$conjur_authn_login_prefix#g" |
    sed "s#{{ CONFIG_MAP_NAME }}#$TEST_APP_NAMESPACE_NAME#g" |
    sed "s#{{ CONJUR_ACCOUNT }}#$CONJUR_ACCOUNT#g" |
    sed "s#{{ CONJUR_APPLIANCE_URL }}#$conjur_appliance_url#g" |
    $cli create -f -

  if [[ "$PLATFORM" == "openshift" ]]; then
    oc expose service test-app-secretless
  fi

  echo "Secretless test app deployed."
}

main $@

