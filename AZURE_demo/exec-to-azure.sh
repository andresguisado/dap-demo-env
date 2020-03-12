#!/bin/bash

if [[ $# != 1 ]]; then
  echo "Usage: $0 [ 1 | 2 ]"
  exit -1
fi

source conjur_setup/azure.config

case $1 in
  1) AZURE_PUB_DNS=$AZ_DNS1
	;;
  2) AZURE_PUB_DNS=$AZ_DNS2
	;;
  *) echo "Specify 1 or 2"
	exit -1
	;;
esac

ssh -i $AZURE_SSH_KEY $LOGIN_USER@$AZURE_PUB_DNS
