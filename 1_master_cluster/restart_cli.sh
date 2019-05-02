#!/bin/bash 
set -o pipefail

. ../utils.sh

  echo "Removing running CLI container..."
  docker stop conjur-cli; docker rm conjur-cli

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

	# initialize cli for connection to master
  docker exec -it $CLI_CONTAINER_NAME bash -c "echo yes | conjur init -a $CONJUR_ACCOUNT -u $CONJUR_APPLIANCE_URL --force=true"
  docker exec $CLI_CONTAINER_NAME conjur authn login -u admin -p $CONJUR_ADMIN_PASSWORD
  docker exec $CLI_CONTAINER_NAME mkdir /policy

  echo "CLI container configured."
