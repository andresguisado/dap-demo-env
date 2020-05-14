#!/bin/bash
source conjur_setup/azure.config

CLOUD_DIRS="conjur_setup"
set -x
for i in $CLOUD_DIRS; do
  scp -r -i $AZURE_SSH_KEY $LOGIN_USER@$AZURE_PUB_DNS:~/$i .
done
