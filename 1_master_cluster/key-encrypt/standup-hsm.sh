#!/bin/bash

export CENTOS_IMAGE=centos:7
export HSM_CONTAINER_NAME=hsm-host
export NSS_SOFTKN_RPM=nss-softokn-freebl-3.44.0-5.el7.x86_64.rpm

docker run -d \
    --name $HSM_CONTAINER_NAME \
    --restart always \
    --entrypoint sh \
    $CENTOS_IMAGE \
    -c "sleep infinity"
exit

docker cp $NSS_SOFTKN_RPM $HSM_CONTAINER_NAME:/tmp
docker exec $HSM_CONTAINER_NAME yum install /tmp/$NSS_SOFTKN_RPM
