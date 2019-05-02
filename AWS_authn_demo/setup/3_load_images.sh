#!/bin/bash
source ./aws.config
echo "Loading Conjur appliance image..."
sudo docker load -i $IMAGE_DIR/$CONJUR_APPLIANCE_IMAGE_FILE
