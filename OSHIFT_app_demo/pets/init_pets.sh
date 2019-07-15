#!/bin/bash
if [ $PLATFORM = openshift ]; then
  PETSTORE_ADDRESS=$(oc get route | grep test-app-secretless | awk '{print $2}')
else
  PETSTORE_ADDRESS=$CONJUR_MASTER_HOST_IP:30512
fi

echo "Pets in PetDB:"
curl -s $PETSTORE_ADDRESS/pets

echo "Adding Lilah..."
curl -XPOST --data '{ "name": "Lilah" }' -H "Content-Type: application/json" $PETSTORE_ADDRESS/pet
echo "Adding Lev..."
curl -XPOST --data '{ "name": "Lev" }' -H "Content-Type: application/json" $PETSTORE_ADDRESS/pet
echo "Adding Tony..."
curl -XPOST --data '{ "name": "Tony" }' -H "Content-Type: application/json" $PETSTORE_ADDRESS/pet
echo "Adding Gus..."
curl -XPOST --data '{ "name": "Gus" }' -H "Content-Type: application/json" $PETSTORE_ADDRESS/pet

echo "Pets in PetDB:"
curl -s $PETSTORE_ADDRESS/pets
echo
echo
