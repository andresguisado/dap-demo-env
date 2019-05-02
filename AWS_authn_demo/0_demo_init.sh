#!/bin/bash
##########################################
##  This script executes on local host  ##
##    All others execute on AWS host    ##
##########################################

# Location of local Conjur appliance tarfile to copy to AWS
CONJUR_TARFILE_SOURCE_DIR=~/conjur-install-images

# sync local & remote config files 
source ./aws.config
scp -i $AWS_SSH_KEY ./aws.config ubuntu@$AWS_PUB_DNS:~ 

# EITHER copy over appliance tarfile...
#scp -i $AWS_SSH_KEY \
#	$CONJUR_TARFILE_DIR/$CONJUR_APPLIANCE_IMAGE_FILE \
#	ubuntu@$AWS_PUB_DNS:~/$IMAGE_DIR
# OR mount snapshotted volume w/ image on it
ssh -i $AWS_SSH_KEY ubuntu@$AWS_PUB_DNS << END_INPUT
  source ./aws.config
  mkdir -p $IMAGE_DIR
  sudo mount $EBS_BLK_DEV $IMAGE_DIR
END_INPUT

# Copy contents of this directory to AWS
scp -r -i $AWS_SSH_KEY ./* ubuntu@$AWS_PUB_DNS:~ 

# Run install/config script
cat _install_demo.sh | ssh -i $AWS_SSH_KEY ubuntu@$AWS_PUB_DNS

# exec to AWS EC2 instance to run demo
./exec-to-aws.sh

