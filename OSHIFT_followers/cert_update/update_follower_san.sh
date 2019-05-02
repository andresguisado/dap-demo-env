#!/bin/bash -x

FOLLOWER_ALTNAMES=$FOLLOWER_ALTNAMES,conjur-follower-cyberark.192.168.99.100.nip.io
docker exec $CONJUR_MASTER_CONTAINER_NAME evoke ca issue --force conjur-follower $FOLLOWER_ALTNAMES
docker exec $CONJUR_MASTER_CONTAINER_NAME evoke seed follower conjur-follower > $FOLLOWER_SEED_FILE
