#!/bin/bash -e

source ../config/dap.config
source ../config/openshift.config

export MINISHIFT_VM_MEMORY=8GB
export OPENSHIFT_VERSION=v3.9.0
export SSH_PUB_KEY=~/.ssh/id_dapdemo.pub

if [[ $PLATFORM != openshift ]]; then
  echo "Platform not set to 'openshift'."
  echo "Edit and source demo.config before running this script."
  exit -1
fi

case $1 in
  stop )
	minishift stop

	# enable app naps again
	defaults write NSGlobalDomain NSAppSleepDisabled -bool NO

	exit 0
	;;
  delete )
	minishift delete --clear-cache
	rm -rf $KUBECONFIGDIR $DAP_HOME/.minishift ~/.kube
	exit 0
	;;
  reinstall )
	minishift delete --clear-cache
	rm -rf $KUBECONFIGDIR $DAP_HOME/.minishift ~/.kube
        unset KUBECONFIG
	;;
  start )
	if [[ ! -f $KUBECONFIG ]]; then
	  unset KUBECONFIG
	fi

	# disable mac app sleep mode
	defaults write NSGlobalDomain NSAppSleepDisabled -bool YES
	;;
  * ) 
	echo "Usage: $0 [ reinstall | start | stop | delete ]"
	exit -1
	;;
esac

if [[ "$(minishift status | grep Running)" != "" ]]; then
  echo "Your minishift environment is already up - skipping creation!"
  exit 0
else
  echo "VM snapshots available. Stop & restore before starting:"
  set +e
  vboxmanage snapshot minishift list
  set -e
  minishift start --memory "$MINISHIFT_VM_MEMORY" \
		  --disk-size "30G" \
                  --vm-driver virtualbox \
                  --show-libmachine-logs \
                  --openshift-version "$OPENSHIFT_VERSION"

  # minikube also wants to use .kube, the default for KUBECONFIG
  # copy contents of .kube to $KUBECONFIGDIR set KUBECONFIG to point there
  if [[ ! -d $KUBECONFIGDIR ]]; then
    mkdir -p $KUBECONFIGDIR
    cp -r ~/.kube/* $KUBECONFIGDIR
    rm -rf ~/.kube
    export KUBECONFIG=$KUBECONFIGDIR/config
  fi
fi
echo "Getting docker env..."
eval $(minishift docker-env)

# clean up exited containers
set +e
docker rm $(docker container ls -a | grep Exited | awk '{print $1}')
set -e

# turn off auto-sleep & install ntpdate in minishift VM and sync its clock
echo "sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target; \
	sudo yum install -y ntpdate; sudo ntpdate pool.ntp.org" | minishift ssh

# add public key to authorized keys for SSH demos
echo "echo $(cat $SSH_PUB_KEY) >> ~/.ssh/authorized_keys" | minishift ssh

## Write Minishift docker & oc config values as env var inits to speed up env loading
OUTPUT_FILE=./minishift.config
minishift oc-env > $OUTPUT_FILE
minishift docker-env >> $OUTPUT_FILE
echo "export DOCKER_REGISTRY_PATH=$(minishift openshift registry)" >> $OUTPUT_FILE
echo "export CONJUR_MASTER_HOST_IP=$(minishift ip)" >> $OUTPUT_FILE

echo ""
echo "IMPORTANT!  IMPORTANT!  IMPORTANT!  IMPORTANT!"
echo "You need to source ../demo.config again to reference docker daemon in Minishift..."
echo ""
