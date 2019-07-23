#!/bin/bash
TOWER_VERSION=3.4.4-1
#sudo sysctl -w net.ipv4.ip_forward=1
docker build --no-cache --squash -t ansible-tower:${TOWER_VERSION} .
