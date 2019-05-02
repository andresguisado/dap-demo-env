#!/bin/bash 
if [[ "$1" != stop && "$1" != start ]]; then
  echo "Usage: $0 [ stop | start ]"
  exit -1
fi
if [[ "$PLATFORM" == "" ]]; then
  source demo.config
fi
if [[ $1 == start ]]; then
  DIRS="1_master_cluster 2_epv_synchronizer OSHIFT_followers CICD_demos JENKINS_demo SPLUNK_demo OSHIFT_app_demo"
else
  DIRS="OSHIFT_app_demo SPLUNK_demo JENKINS_demo OSHIFT_followers CICD_demos 1_master_cluster"
fi
for i in $DIRS; do
  pushd $i && ./$1
  if [[ $i == 2_epv_synchronizer ]]; then
    read -n1 -r -p "Start synchronizer, press space to continue..." key
  fi
  popd
done
