#!/bin/bash
##########################################
##  This script executes on local host  ##
##    All others execute on AWS host    ##
##########################################

SETUP_DIR=./conjur_setup
DEMO_DIR=./demo

# sync local & remote config files 
source $SETUP_DIR/aws.config

if [[ "$AWS_PUB_DNS" == "" ]]; then
  echo "Please edit $SETUP_DIR/aws.config and set AWS_PUB_DNS to DNS name of Conjur host."
  exit -1
fi

# EITHER copy over appliance tarfile...
# Location of local Conjur appliance tarfile to copy to AWS
#CONJUR_TARFILE_SOURCE_DIR=~/conjur-install-images
#echo "mkdir $IMAGE_DIR" | ssh -i $AWS_SSH_KEY ubuntu@$AWS_PUB_DNS
#scp -i $AWS_SSH_KEY \
#	$CONJUR_TARFILE_SOURCE_DIR/$CONJUR_APPLIANCE_IMAGE_FILE \
#	ubuntu@$AWS_PUB_DNS:$IMAGE_DIR
# OR mount snapshotted volume w/ image on it

# Copy subdirectories to AWS
scp -r -i $AWS_SSH_KEY $SETUP_DIR ubuntu@$AWS_PUB_DNS:~ 
scp -r -i $AWS_SSH_KEY $DEMO_DIR ubuntu@$AWS_PUB_DNS:~ 

# exec to AWS EC2 instance to install & run demo
ssh -i $AWS_SSH_KEY ubuntu@$AWS_PUB_DNS 
