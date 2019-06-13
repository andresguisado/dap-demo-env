#!/bin/bash 
set -o pipefail

. ../utils.sh

main() {
  scope launch
  master_network_up
  shared_volumes_up
  master_up
  cli_up
  echo
}

############################
master_network_up() {
  docker network create $CONJUR_NETWORK
}

############################
shared_volumes_up() {
  docker volume create $CONJUR_AUDIT_VOLUME
  docker volume create $CONJUR_NGINX_VOLUME
}

############################
master_up() {
  echo "-----"
  announce "Initializing Conjur Master"
  docker run -d \
    --name $CONJUR_MASTER_CONTAINER_NAME \
    --label role=conjur_node \
    -p "2222:22" \
    -p "$CONJUR_MASTER_PORT:443" \
    -p "$CONJUR_MASTER_PGSYNC_PORT:5432" \
    -p "$CONJUR_MASTER_PGAUDIT_PORT:1999" \
    --restart always \
    --volume $CONJUR_AUDIT_VOLUME:/var/log/conjur \
    --volume $CONJUR_NGINX_VOLUME:/var/log/nginx \
    --security-opt seccomp:unconfined \
    $CONJUR_APPLIANCE_IMAGE

  docker network connect $CONJUR_NETWORK $CONJUR_MASTER_CONTAINER_NAME

  docker exec -it $CONJUR_MASTER_CONTAINER_NAME \
    evoke configure master \
    -h $CONJUR_MASTER_HOST_NAME \
    -p $CONJUR_ADMIN_PASSWORD \
    --master-altnames "$MASTER_ALTNAMES" \
    --follower-altnames "$FOLLOWER_ALTNAMES" \
    $CONJUR_ACCOUNT

  echo "Caching Certificate from Conjur..."
  mkdir -p $CACHE_DIR
  rm -f $CONJUR_CERT_FILE
					# cache cert for copying to other containers
  docker cp -L $CONJUR_MASTER_CONTAINER_NAME:/opt/conjur/etc/ssl/conjur.pem $CONJUR_CERT_FILE

  echo "Caching Conjur Follower seed files..."
  docker exec $CONJUR_MASTER_CONTAINER_NAME evoke seed follower conjur-follower > $FOLLOWER_SEED_FILE
}

############################
cli_up() {

  announce "Creating CLI container."

  docker run -d \
    --name $CLI_CONTAINER_NAME \
    --label role=cli \
    --restart always \
    --security-opt seccomp:unconfined \
    --entrypoint sh \
    $CLI_IMAGE_NAME \
    -c "sleep infinity" 

  echo "CLI container launched."

  if [[ $NO_DNS == true ]]; then
    # add entry for master host name to cli container's /etc/hosts 
    docker exec -it $CLI_CONTAINER_NAME bash -c "echo \"$CONJUR_MASTER_HOST_IP    $CONJUR_MASTER_HOST_NAME\" >> /etc/hosts"
  fi

  wait_till_master_is_responsive
	# initialize cli for connection to master
  docker exec -it $CLI_CONTAINER_NAME bash -c "echo yes | conjur init -a $CONJUR_ACCOUNT -u $CONJUR_APPLIANCE_URL --force=true"
  docker exec $CLI_CONTAINER_NAME conjur authn login -u admin -p $CONJUR_ADMIN_PASSWORD
  docker exec $CLI_CONTAINER_NAME mkdir /policy

  echo "CLI container configured."
}

############################
wait_till_master_is_responsive() {
  set +e
  master_is_healthy=""
  while [[ "$master_is_healthy" == "" ]]; do
    sleep 2
    master_is_healthy=$(docker exec -it conjur-cli curl -k $CONJUR_APPLIANCE_URL/health | grep "ok" | tail -1 | grep "true")
  done
  set -e
}

main $@
