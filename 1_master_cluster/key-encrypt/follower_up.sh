#!/bin/bash

# If the Master keys are encrypted, you must decrypt-all before running this script.

export CONJUR_APPLIANCE_IMAGE=conjur-appliance:11.2.1
export CONJUR_MASTER_CONTAINER_NAME=conjur1
export CONJUR_MASTER_HOST_NAME=conjur-master-vbx
export CONJUR_MASTER_HOST_IP=192.168.99.100
export FOLLOWER_SEED_FILE=./follower-seed.tar
export CONJUR_FOLLOWER_CONTAINER_NAME=conjur-follower
export CONJUR_FOLLOWER_PORT=30444
export AUTHENTICATOR_ID=dappoc
export CONJUR_AUTHENTICATORS=authn,authn-k8s/$AUTHENTICATOR_ID

./stop

# Generate seed file from master keys
docker exec -i $CONJUR_MASTER_CONTAINER_NAME \
	evoke seed follower $CONJUR_MASTER_HOST_NAME > $FOLLOWER_SEED_FILE

# Bring up Conjur Follower node
docker run -d \
    --name $CONJUR_FOLLOWER_CONTAINER_NAME \
    --label role=conjur_node \
    -p "$CONJUR_FOLLOWER_PORT:443" \
    -e "CONJUR_AUTHENTICATORS=$CONJUR_AUTHENTICATORS" \
    --restart always \
    --security-opt seccomp:unconfined \
    $CONJUR_APPLIANCE_IMAGE

if $NO_DNS; then
    # add entry to follower's /etc/hosts so $CONJUR_MASTER_HOST_NAME resolves
    docker exec -it $CONJUR_FOLLOWER_CONTAINER_NAME \
        bash -c "echo \"$CONJUR_MASTER_HOST_IP $CONJUR_MASTER_HOST_NAME\" >> /etc/hosts"
fi

echo "Initializing Conjur Follower"
docker cp $FOLLOWER_SEED_FILE \
                $CONJUR_FOLLOWER_CONTAINER_NAME:/tmp/follower-seed.tar
docker exec $CONJUR_FOLLOWER_CONTAINER_NAME \
                evoke unpack seed /tmp/follower-seed.tar
docker exec $CONJUR_FOLLOWER_CONTAINER_NAME \
                evoke configure follower -p $CONJUR_MASTER_PORT

echo "Follower configured."
