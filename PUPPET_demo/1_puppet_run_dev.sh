#!/bin/bash 

source ../config/dap.config

docker-compose exec dev-webapp puppet agent -t
echo
echo "value stored in /etc/mysecretkey:"
docker-compose exec dev-webapp cat /etc/mysecretkey
echo
