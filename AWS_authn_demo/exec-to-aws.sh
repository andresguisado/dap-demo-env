#!/bin/bash
##########################################
##  This script Executes on local host  ##
##########################################

source ./aws.config
set -x
ssh -i $AWS_SSH_KEY ubuntu@$AWS_PUB_DNS
