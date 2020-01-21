#!/bin/bash
export ANSIBLE_MODULE=ping
export ENV=prod
export USER_NAME=docker
set -x
summon bash -c "ansible -m $ANSIBLE_MODULE -i ./ansible_hosts $ENV --private-key=\$SSH_KEY -u $USER_NAME"
