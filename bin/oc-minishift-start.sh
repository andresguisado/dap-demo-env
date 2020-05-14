#!/bin/bash -e

rm -f $DAP_HOME/config/minishift.env

                # set DAP_HOME to parent directory of this script
DAP_HOME="$(ls $0 | rev | cut -d "/" -f2- | rev)/.."
source $DAP_HOME/config/dap.config

export MINISHIFT_VM_MEMORY=8GB
export OPENSHIFT_VERSION=v3.11.0
export SSH_PUB_KEY=~/.ssh/id_dapdemo.pub
export MINISHIFT_CACHE_TARFILE=~/conjur-install-images/minishift-3.11-cache.tar.gz

if [[ $K8S_PLATFORM != minishift ]]; then
  echo
  echo "K8S_PLATFORM is currently set to $K8S_PLATFORM."
  echo "Edit dap.config and change to 'minishift' before running this script."
  echo
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
	rm -rf $KUBECONFIGDIR ~/.minishift ~/.kube
	exit 0
	;;
  reinstall )
	minishift delete --clear-cache
	rm -rf $KUBECONFIGDIR ~/.minishift ~/.kube
	if [[ -f ${MINISHIFT_CACHE_TARFILE} ]]; then
	  echo -n "Restoring cached images from ${MINISHIFT_CACHE_TARFILE}..."
	  mkdir ~/.minishift && cd ~/.minishift && tar xvf ${MINISHIFT_CACHE_TARFILE}
	  echo "done."
	fi
        unset KUBECONFIG

	;;
  start )
	if [[ ! -f $KUBECONFIG ]]; then
	  unset KUBECONFIG
	fi
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
 		  --insecure-registry "192.168.1.0/24" \
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

# disable mac app sleep mode
defaults write NSGlobalDomain NSAppSleepDisabled -bool YES

# turn off auto-sleep & install ntpdate in minishift VM and sync its clock
echo "sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target; \
	sudo yum install -y ntpdate; sudo ntpdate pool.ntp.org" | minishift ssh

# add public key to authorized keys for SSH demos
echo "echo $(cat $SSH_PUB_KEY) >> ~/.ssh/authorized_keys" | minishift ssh

# Write Minishift oc config values as env var inits to speed up env loading
K8S_ENV_FILE=$DAP_HOME/config/minishift.env
rm -f $K8S_ENV_FILE
minishift oc-env > $K8S_ENV_FILE

# Write Minishift docker config values as env var inits 
DOCKER_ENV_FILE=$DAP_HOME/config/minishift.docker
rm -f $DOCKER_ENV_FILE
minishift docker-env > $DOCKER_ENV_FILE
echo "export DOCKER_PLATFORM_REGISTRY_URL=$(minishift openshift registry)" >> $DOCKER_ENV_FILE

echo ""
echo "Source $OUTPUT_FILE to point to docker daemon in minishift VM."
echo ""
