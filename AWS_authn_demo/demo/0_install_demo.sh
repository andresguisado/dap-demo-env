#!/bin/bash
########################################
##  This script executes on AWS host  ##
########################################

source ./demo.config

main() {
  ruby_setup
  install_summon
  load_policies
}

ruby_setup() {
  sudo apt-get update
  sudo apt-get install -qy ruby-dev rubygems build-essential
  # use -V argument for verbose gem install output
  sudo gem install aws-sdk-core
  sudo gem install aws-sigv4
  sudo gem install conjur-api
}

install_summon() {
  ###
  # Also install Summon and create directory for providers
  pushd /tmp
  curl -LO https://github.com/cyberark/summon/releases/download/v0.6.7/summon-linux-amd64.tar.gz \
    && tar xzf summon-linux-amd64.tar.gz \
    && sudo mv summon /usr/local/bin/ \
    && rm summon-linux-amd64.tar.gz
  popd
}

load_policies() {
   printf "\nEnter admin user name: "
   read admin_uname
   printf "Enter the admin password (it will not be echoed): "
   read -s admin_pwd
   export AUTHN_USERNAME=$admin_uname
   export AUTHN_PASSWORD=$admin_pwd

  ./load_policy_REST.sh root policy/authn-iam.yaml
  ./load_policy_REST.sh root policy/cust-portal.yaml
  ./load_policy_REST.sh root policy/authn-grant.yaml
  ./var_value_add_REST.sh $APPLICATION_NAME/database/username OracleDBuser
  ./var_value_add_REST.sh $APPLICATION_NAME/database/password ueus#!9
}

main "$@"
