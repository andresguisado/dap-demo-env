#!/bin/bash
. ../../config/dap.config
. ../../config/$PLATFORM.config

PETSTORE_ADDRESS=$CONJUR_MASTER_HOST_IP:8080

echo "Deleting pets 1-4.."
curl -XDELETE $PETSTORE_ADDRESS/pet/1
curl -XDELETE $PETSTORE_ADDRESS/pet/2
curl -XDELETE $PETSTORE_ADDRESS/pet/3
curl -XDELETE $PETSTORE_ADDRESS/pet/4
