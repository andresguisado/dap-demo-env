#!/bin/bash 
ANSIBLE_MODULE=$1
HOST_SPEC=$2
echo "USER_NAME: $USER_NAME"
echo "SSH_KEY: $SSH_KEY"
ansible -m $ANSIBLE_MODULE -i ./ansible_hosts $HOST_SPEC --private-key=$SSH_KEY -u $USER_NAME
