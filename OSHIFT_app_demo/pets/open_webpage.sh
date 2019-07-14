#!/bin/bash
if [ $PLATFORM = openshift ]; then
  PETSTORE_ADDRESS=$(oc get route | grep test-app-secretless | awk '{print $2}')
else
  PETSTORE_ADDRESS=$CONJUR_MASTER_HOST_IP:33333
fi
open http://$PETSTORE_ADDRESS/pets
