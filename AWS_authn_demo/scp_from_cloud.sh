#!/bin/bash
source conjur_setup/aws.config

CLOUD_DIRS="conjur_setup ruby python java"
set -x
for i in $CLOUD_DIRS; do
  scp -r -i $AWS_SSH_KEY ubuntu@$AWS_PUB_DNS:~/$i .
done
