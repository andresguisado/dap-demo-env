#!/bin/bash
if [[ $# < 1 ]]; then
  echo "Usage: $0 <pet-number>"
  exit -1
fi
PET_NUMBER=$1

if [ $PLATFORM = openshift ]; then
  PETSTORE_ADDRESS=$(oc get route | grep test-app-secretless | awk '{print $2}')
else
  PETSTORE_ADDRESS=$CONJUR_MASTER_HOST_IP:30512
fi

echo
./list_pets.sh

echo "Deleting pet number $PET_NUMBER.."
curl -XDELETE $PETSTORE_ADDRESS/pet/$PET_NUMBER

echo
./list_pets.sh
