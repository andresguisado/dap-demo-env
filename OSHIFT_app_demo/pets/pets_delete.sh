#!/bin/bash
if [ $PLATFORM = openshift ]; then
  PETSTORE_ADDRESS=$(oc get route | grep test-app-secretless | awk '{print $2}')
else
  PETSTORE_ADDRESS=$CONJUR_MASTER_HOST_IP:33333
fi

echo "Deleting 4 pets.."
curl -XDELETE $PETSTORE_ADDRESS/pet/1
curl -XDELETE $PETSTORE_ADDRESS/pet/2
curl -XDELETE $PETSTORE_ADDRESS/pet/3
curl -XDELETE $PETSTORE_ADDRESS/pet/4
