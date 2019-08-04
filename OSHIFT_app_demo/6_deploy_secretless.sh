#!/bin/bash
set -eo pipefail

. utils.sh

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

  # deploy secretless backend servers - ssh connects to minishift vm as backend
  deploy_pg_database
  deploy_mysql_database
  deploy_nginx

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
  secretless_app_image=$(platform_image secretless)
  secretless_broker_image=$(platform_image secretless-broker)
  authenticator_client_image=$(platform_image conjur-authn-k8s-client)

  conjur_appliance_url=https://conjur-follower.$CONJUR_NAMESPACE_NAME.svc.cluster.local/api
  conjur_authenticator_url=https://conjur-follower.$CONJUR_NAMESPACE_NAME.svc.cluster.local/api/authn-k8s/$AUTHENTICATOR_ID

  conjur_authn_login_prefix=host/conjur/authn-k8s/$AUTHENTICATOR_ID/apps/$TEST_APP_NAMESPACE_NAME/service_account
  $cli delete --ignore-not-found secret test-app-backend-certs
  $cli --namespace $TEST_APP_NAMESPACE_NAME \
      create secret generic \
      test-app-backend-certs \
      --from-file=server.crt=./etc/ca.pem \
      --from-file=server.key=./etc/ca-key.pem
}

###########################
create_k8s_secrets() {

  $cli delete --ignore-not-found secret test-app-secret
  $cli create secret generic test-app-secret \
	--from-literal=secret-key=Can-You-Read-This-Secret?
}

###########################
deploy_mysql_database() {
  $cli delete --ignore-not-found \
     service/mysql-db \
     statefulset/mysql-db

  ensure_env_database

  # Create the random database password
  MYSQL_DB_PASSWORD=$(openssl rand -hex 12)

  # Set DB DB_PASSWORD in platform manifest
  sed "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" ./$PLATFORM/mysql.template.yml |
    sed "s#{{ TEST_APP_DB_PASSWORD }}#$MYSQL_DB_PASSWORD#g" ./$PLATFORM/mysql.template.yml \
    > ./$PLATFORM/tmp.${TEST_APP_NAMESPACE_NAME}.mysql.yml
  
  MYSQL_DB_PROTOCOL=mysql
  MYSQL_DB_NAME=test_app
  MYSQL_DB_HOST=mysql-db
  MYSQL_DB_PORT=3306
  MYSQL_DB_USERNAME=test_app
  MYSQL_DB_SSLMODE=disable

  ./var_value_add_REST.sh test-app-secretless/mysql-host $MYSQL_DB_HOST
  ./var_value_add_REST.sh test-app-secretless/mysql-port $MYSQL_DB_PORT
  ./var_value_add_REST.sh test-app-secretless/mysql-username $MYSQL_DB_USERNAME
  ./var_value_add_REST.sh test-app-secretless/mysql-password $MYSQL_DB_PASSWORD
  ./var_value_add_REST.sh test-app-secretless/mysql-sslmode $MYSQL_DB_SSLMODE

  echo "Deploying mysql backend"

  test_app_mysql_docker_image="mysql/mysql-server:5.7"

  sed "s#{{ IMAGE_NAME }}#$test_app_mysql_docker_image#g" \
		./$PLATFORM/tmp.${TEST_APP_NAMESPACE_NAME}.mysql.yml |
    sed "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" |
    sed "s#{{ IMAGE_PULL_POLICY }}#$IMAGE_PULL_POLICY#g" |
    $cli create -f -
}

###########################
deploy_pg_database() {
  $cli delete --ignore-not-found \
     service/postgres-db \
     statefulset/postgres-db

  ensure_env_database

  # Create the random database password
  PG_DB_PASSWORD=$(openssl rand -hex 12)

  # Set DB_PASSWORD in platform manifest
  sed "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" ./$PLATFORM/postgres.template.yml |
    sed "s#{{ TEST_APP_DB_PASSWORD }}#$PG_DB_PASSWORD#g" ./$PLATFORM/postgres.template.yml \
    > ./$PLATFORM/tmp.${TEST_APP_NAMESPACE_NAME}.postgres.yml

  PG_DB_NAME=test_app
  PG_DB_USERNAME=test_app
  PG_DB_SSLMODE=disable
  PG_DB_HOST=postgres-db
  PG_DB_PORT=5432
  PG_DB_PROTOCOL=postgresql
  PG_DB_ADDRESS="$PG_DB_HOST:$PG_DB_PORT/$PG_DB_NAME"
  # Set connections values in Conjur
  ./var_value_add_REST.sh test-app-secretless/pg-address $PG_DB_ADDRESS
  ./var_value_add_REST.sh test-app-secretless/pg-username $PG_DB_USERNAME
  ./var_value_add_REST.sh test-app-secretless/pg-password $PG_DB_PASSWORD
  ./var_value_add_REST.sh test-app-secretless/pg-sslmode $PG_DB_SSLMODE

  echo "Deploying postgres backend"

  test_app_pg_docker_image=$(platform_image pgsql)

  sed "s#{{ IMAGE_NAME }}#$test_app_pg_docker_image#g" ./$PLATFORM/tmp.${TEST_APP_NAMESPACE_NAME}.postgres.yml |
    sed "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" |
    sed "s#{{ IMAGE_PULL_POLICY }}#$IMAGE_PULL_POLICY#g" |
    $cli create -f -

    setup_pg_logging
}

###########################
setup_pg_logging() {  #  Adds connection & disconnection logging
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
}

###########################
deploy_nginx() {
  $cli delete --ignore-not-found \
     service/nginx \
     statefulset/nginx

  echo "Deploying nginx backend"

  nginx_image=$(platform_image nginx-ocp)

  # Note: all server-side authn creds are provisioned in the image build
  # Which begs the question - how would you ever rotate that?

  HTTP_UNAME=demo
  HTTP_PWD=demo
  ./var_value_add_REST.sh test-app-secretless/http-username $HTTP_UNAME
  ./var_value_add_REST.sh test-app-secretless/http-password $HTTP_PWD

  sed "s#{{ IMAGE_NAME }}#$nginx_image#g" ./$PLATFORM/nginx.template.yml |
    sed "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g" |
    sed "s#{{ IMAGE_PULL_POLICY }}#$IMAGE_PULL_POLICY#g" |
    $cli create -f -
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

main "$@"

