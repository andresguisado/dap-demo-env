# dap-demo-env

## Configuration files - review and edit first
 - demo.config - master config file
 - openshift.config - config for minishift env
 - kubernetes.config - config for minikube env
 - utils.sh - should not need editing

## Management scripts
 - install_dependencies.sh - installs minikube, minishift, etc.
 - oc-minishift-start.sh - start, stops & reinitialized minishift env
 - k8s-minikube-start.sh - start, stops & reinitialized minikube env
 - 0_load_images - utility for bulk image loading from tarfiles
 - bring_up.sh - starts up demos once minishift/kube are running

## Demo directories
 - 1_master_cluster - starts master & cli in minishift/kube docker daemon
 - 2_epv_synchronizer - initializes new Conjur master for synchronizer
 - CICD_demos - general Summon demo w/ chef, ansible & terraform integration demos
 - JENKINS_demo - Jenkins plugin demo
 - OSHIFT_followers - Follower installation in k8s or Openshift (works for both)
 - OSHIFT_app_demo - Demo app in k8s or Openshift (works for both)
 - SPLUNK_demo - Splunk integration demo
 - AWS_authn_demo - sets up AWS authn-iam demo in AWS (separate master)
 - PKIaaS_demo
 - AIMCCP_demo
 - PUPPET_demo
 - SPRING_demo
 - HFTOKEN_demo
 - POLICY_example

## Works in progress (don't use)
 - CONJUR_cli
 - K8S-app
 - wip_TOWER_demo
