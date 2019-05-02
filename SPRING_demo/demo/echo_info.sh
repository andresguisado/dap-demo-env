#!/bin/bash
source ../spring-demo.config
echo "Contents of /etc/secrets.yml..."
docker exec hello cat /secrets.yml
echo
echo
echo "Opening web page where spring-apps/hello/secret is echoed..."
open http://$CONJUR_MASTER_HOST_NAME:$SPRING_PORT
