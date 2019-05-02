#!/bin/bash -e

if [[ $PLATFORM != openshift ]]; then
  echo "Platform not set to 'openshift'."
  echo "Edit and source demo.config before running this script."
  exit -1
fi

case $1 in
  stop )
	minishift stop
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
  vboxmanage snapshot minishift list
  minishift start --memory "$MINISHIFT_VM_MEMORY" \
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
eval $(minishift docker-env)

# clean up exited containers
docker rm $(docker container ls -a | grep Exited | awk '{print $1}')

# if CLI container is already running, update /etc/hosts and start scope
if [[ ("$(docker ps | grep $CLI_CONTAINER_NAME)" != "") ]]; then
  CONJUR_MASTER_HOST_IP=$(minishift ip) 
  docker exec -it $CLI_CONTAINER_NAME bash -c "echo \"$CONJUR_MASTER_HOST_IP    $CONJUR_MASTER_HOST_NAME\" >> /etc/hosts"
  scope launch >& /dev/null
fi

echo ""
echo "IMPORTANT!  IMPORTANT!  IMPORTANT!  IMPORTANT!"
echo "You need to source ../demo.config again to reference docker daemon in Minishift..."
echo ""
