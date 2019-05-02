#!/bin/bash
source ../spring-demo.config

echo "Listing all pets..."
curl $CONJUR_MASTER_HOST_NAME:$SPRING_PORT/pets
echo
echo
