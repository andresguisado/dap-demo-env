#!/bin/bash

# Brings up and configures a Follower using encrypted Master keys.

source ./keymgmt.config

./stop

# Generate encrypted seed file from encrypted master keys
cat $MASTER_KEY_FILE | docker exec -i $CONJUR_MASTER_CONTAINER_NAME \
	evoke keys exec -m - -- evoke seed follower $CONJUR_MASTER_HOST_NAME > $ENC_FOLLOWER_SEED_FILE

# Bring up Conjur Follower node
docker run -d \
    --name $CONJUR_FOLLOWER_CONTAINER_NAME \
    --label role=conjur_node \
    -p "$CONJUR_FOLLOWER_PORT:443" \
    --restart always \
    --security-opt seccomp:unconfined \
    $CONJUR_APPLIANCE_IMAGE

if $NO_DNS; then
    # add entry to follower's /etc/hosts so $CONJUR_MASTER_HOST_NAME resolves
    docker exec -it $CONJUR_FOLLOWER_CONTAINER_NAME \
        bash -c "echo \"$CONJUR_MASTER_HOST_IP $CONJUR_MASTER_HOST_NAME\" >> /etc/hosts"
fi

echo "Initializing Conjur Follower"
docker cp $ENC_FOLLOWER_SEED_FILE \
                $CONJUR_FOLLOWER_CONTAINER_NAME:/tmp/follower-seed.tar
docker exec -i $CONJUR_FOLLOWER_CONTAINER_NAME \
                evoke unpack seed /tmp/follower-seed.tar
cat $MASTER_KEY_FILE | docker exec -i $CONJUR_FOLLOWER_CONTAINER_NAME \
                evoke keys exec -m - -- evoke configure follower -p $CONJUR_MASTER_PORT

echo "Follower configured."
