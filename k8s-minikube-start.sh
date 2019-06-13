#!/bin/bash

if [[ $PLATFORM != kubernetes ]]; then
  echo "PLATFORM not set to 'kubernetes'."
  echo "Edit and source demo.config before running this script."
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
		  --loglevel $LOGLEVEL \
                  --kubernetes-version "$KUBERNETES_VERSION" \
		  --extra-config=apiserver.admission-control="ServiceAccount,MutatingAdmissionWebhook" \
		  --extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
		  --extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key"

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

# install ntpdate in minikube VM and sync its clock
echo "sudo yum install -y ntpdate; sudo ntpdate pool.ntp.org" | minikube ssh

echo "Waiting for minikube to finish starting..."
minikube status

echo ""
echo "IMPORTANT!  IMPORTANT!  IMPORTANT!  IMPORTANT!"
echo "You need to source kubernetes.config again to reference docker daemon in Minikube..."
echo ""
