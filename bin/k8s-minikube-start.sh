#!/bin/bash

                # set DAP_HOME to parent directory of this script
DAP_HOME="$(ls $0 | rev | cut -d "/" -f2- | rev)/.."
source $DAP_HOME/config/dap.config
source $DAP_HOME/config/kubernetes.config

# 
export MINIKUBE_VM_MEMORY=6144
export KUBERNETES_VERSION=v1.11.10
export SSH_PUB_KEY=~/.ssh/id_dapdemo.pub

if [[ $K8S_PLATFORM != minikube ]]; then
  echo
  echo "K8S_PLATFORM is currently set to $K8S_PLATFORM."
  echo "Edit dap.config and change to 'minikube' before running this script."
  echo
  exit -1
fi

# Minikube LOGLEVEL: 0=Debug, 5=Fatal
LOGLEVEL=0

case $1 in
  stop )
	minikube stop
	exit 0
	;;
  delete )
	minikube delete 
	rm -rf $KUBECONFIGDIR ~/.minikube ~/.kube
	exit 0
	;;
  reinstall )
	minikube delete
	rm -rf $KUBECONFIGDIR ~/.minikube ~/.kube
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

if [[ "$(minikube status | grep Running)" != "" ]]; then
  echo "Your minikube environment is already up - skipping creation!"
else
  echo "VM snapshots available. Stop & restore before starting:"
  vboxmanage snapshot minikube list
  minikube start --memory "$MINIKUBE_VM_MEMORY" \
                  --vm-driver virtualbox \
                  --kubernetes-version "$KUBERNETES_VERSION"
#		  --extra-config=kubelet.config=/var/lib/kubelet/config.yaml \
#		  --extra-config=apiserver.admission-control="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
#		  --loglevel $LOGLEVEL \
#		  --extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
#		  --extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key"

  if [[ ! -d $KUBECONFIGDIR ]]; then
    mkdir $KUBECONFIGDIR
    cp -r ~/.kube/* $KUBECONFIGDIR
    rm -rf ~/.kube
    export KUBECONFIG=$KUBECONFIGDIR/config
  fi
fi
eval $(minikube docker-env)

#remove all taints from the minikube node so that pods will get scheduled
sleep 5
kubectl patch node minikube -p '{"spec":{"taints":[]}}'

# delete Exited containers
docker rm $(docker container ls -a | grep Exited | awk '{print $1}') > /dev/null

echo "Waiting for minikube to finish starting..."
minikube status

# add public key to authorized keys for SSH demos
echo "echo $(cat $SSH_PUB_KEY) >> ~/.ssh/authorized_keys; logout" | minikube ssh

## Write Minishift docker config values as env var inits to speed up env loading
DOCKER_ENV_FILE=$DAP_HOME/config/minikube.docker
rm -f $DOCKER_ENV_FILE
minikube docker-env > $DOCKER_ENV_FILE

echo ""
echo "Source $OUTPUT_FILE to point to docker daemon in minikube VM."
echo ""
