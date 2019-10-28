#!/bin/bash
. ../../config/dap.config
. ../../config/$PLATFORM.config

PETSTORE_ADDRESS=$CONJUR_MASTER_HOST_IP:8080

echo "Listing all pets..."
curl $PETSTORE_ADDRESS/pets
echo
echo
