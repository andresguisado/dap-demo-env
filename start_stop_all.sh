#!/bin/bash 
if [[ "$1" != stop && "$1" != start ]]; then
  echo "Usage: $0 [ stop | start ]"
  exit -1
fi

source demo.config

if [[ $1 == start ]]; then
  DIRS="OSHIFT_followers CICD_demos JENKINS_demo SPLUNK_demo OSHIFT_app_demo"
else
  DIRS="OSHIFT_app_demo SPLUNK_demo JENKINS_demo OSHIFT_followers CICD_demos 1_master_cluster"
fi
for i in $DIRS; do
  pushd $i && ./$1
  popd
done
