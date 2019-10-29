#!/bin/bash
source ../config/dap.config

export PETSTORE_ADDRESS=$CONJUR_MASTER_HOST_IP:8080
open http://$PETSTORE_ADDRESS/pets
