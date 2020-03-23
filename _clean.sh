#!/bin/bash
CLEANUP_DIRS="1_master_cluster AWS_authn_demo HFTOKEN_demo JAVA_demo K8S_apps_demo K8S_followers K8S_injector_demo K8S_secretless_demo SELF_SERVE_demo"
for i in $CLEANUP_DIRS; do
  pushd $i
   ./_clean.sh
  popd
done
