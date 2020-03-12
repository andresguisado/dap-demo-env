#!/bin/bash

function main() {
   load_policies
   exit
   initialize_variables
   initialize_authenticator
}

function load_policies() {
  ./load_policy_REST.sh root policy/azure-authn.yml delete
  ./load_policy_REST.sh root policy/azure-apps.yml delete
  ./load_policy_REST.sh root policy/azure-resources.yml delete
}

function initialize_variables() {

  ./var_value_add_REST.sh conjur/authn-azure/sub1/provider-uri "https://sts.windows.net/dc5c35ed-5102-4908-9a31-244d3e0134c6/"
  ./var_value_add_REST.sh conjur/authn-azure/sub2/provider-uri "https://sts.windows.net/28c8a937-c067-4de3-970b-3355986ac806/"

  ./var_value_add_REST.sh test-var-sub1-rgrp1 "value-of-test-var-sub1-rgrp1"
  ./var_value_add_REST.sh test-var-sub1-rgrp1-sid1 "value-of-test-var-sub1-rgrp1-sid1" 
  ./var_value_add_REST.sh test-var-sub1-rgrp1-uid1 "value-of-test-var-sub1-rgrp2-uid1" 
  ./var_value_add_REST.sh test-var-sub1-rgrp2-uid1 "value-of-test-var-sub1-rgrp2-uid1" 

  ./var_value_add_REST.sh test-var-sub2-rgrp1 "value-of-test-var-sub2-rgrp1" 
  ./var_value_add_REST.sh test-var-sub2-rgrp1-sid1 "value-of-test-var-sub2-rgrp1-sid1" 
  ./var_value_add_REST.sh test-var-sub2-rgrp1-uid1 "value-of-test-var-sub2-rgrp1-uid1" 
}

function initialize_authenticator() {
  sudo docker exec conjur-master evoke variable set CONJUR_AUTHENTICATORS authn,authn-azure/sub1,authn-azure/sub2
}

main "$@"
