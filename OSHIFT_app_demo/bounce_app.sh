#!/bin/bash

. ./utils.sh

if [[ $PLATFORM == openshift ]]; then
  $cli scale --replicas=0 dc test-app-secretless
  $cli scale --replicas=1 dc test-app-secretless
else
  $cli scale --replicas=0 deployment test-app-secretless
  $cli scale --replicas=1 deployment test-app-secretless
fi
