#!/bin/bash 
########################################
##  This script executes on AWS host  ##
########################################

source ./demo.config

if [[ "$(cat /etc/os-release | grep 'Ubuntu 18')" == "" ]]; then
  echo "These installation scripts assume Ubuntu 18"
  exit -1
fi

if [[ "$CONJUR_MASTER_HOST_NAME" == "" ]]; then
  echo "Please edit demo.config and set CONJUR_MASTER_HOST_NAME to the Public DNS hostname of the Conjur Master."
  exit -1
fi

./load_policy_REST.sh root policy/authn-iam.yaml
./load_policy_REST.sh root policy/cust-portal.yaml
./load_policy_REST.sh root policy/authn-grant.yaml
./var_value_add_REST.sh $APPLICATION_NAME/database/username OracleDBuser
./var_value_add_REST.sh $APPLICATION_NAME/database/password ueus#!9
