# dap-demo-env

General demo environment for DAP showing various tool and platform integrations.

## Configuration files - review and edit first
 - ./config/dap.config - master config file
 - ./config/openshift.config - config for OCP env
 - ./config/kubernetes.config - config for K8s env
 - ./config/utils.sh - utility bash functions, does not need editing

## Management scripts
 - ./bin/demoshell/ - directory for building demoshell container
 - ./bin/install_dependencies.sh - installs minikube, minishift, etc. on host 
 - ./bin/oc-minishift-start.sh - start, stops & reinitialized minishift env
 - ./bin/k8s-minikube-start.sh - start, stops & reinitialized minikube env
 - ./bin/start_stop_all.sh - starts up demos once minishift/kube are running
 - ./bin/strt_k8sdash.sh - starts k8s dashboard for docker desktop k8s
 - ./bin/stp_k8sdash.sh - stops k8s dashboard for docker desktop k8s
 - ./bin/k8sdashboard.yaml - yaml for k8s dashboard for docker desktop k8s
 - ./bin/load_policy_REST.sh - script that loads DAP policy w/ REST call
 - ./bin/var_value_add_REST.sh - script that sets DAP variable w/ REST call

## Demo directories
 - 1_master_cluster - starts master & cli in minishift/kube docker daemon
 - 2_epv_synchronizer - initializes new DAP master for synchronizer
 - AIMCCP_demo - playbook that formats a REST call to CCP
 - AWS_authn_demo - sets up AWS authn-iam demo in AWS (separate master)
 - CICD_demos - general Summon demo w/ chef, ansible & terraform integration demos
 - JAVA_demo - simple java client that pulls a secret
 - JENKINS_demo - Jenkins plugin demo
 - K8S_apps_demo - Demo app in k8s or Openshift (works for both)
 - K8S_followers - Follower installation in k8s or Openshift (works for both)
 - K8S_secretless_demo - Secretless demo app in k8s or Openshift (works for both)
 - POLICY_example - example policies showing best practices
 - PSM4C_demo - policy to setup access to EPV secrets for DAP user
 - PUPPET_demo - builds Puppet server, configures agents on nodes
 - SPLUNK_demo - Splunk integration demo
 - SPRING_demo - shows secrets injection for Spring resource files
 - HFTOKEN_demo - Host factory token lifecycle

## Works in progress (don't use)
 - wip_GO_demo
 - wip_K8S_sideinjector
 - wip_PKIaaS_demo
 - wip_TOWER_demo
