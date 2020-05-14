#!/bin/bash
                # set DAP_HOME to parent directory of this script
DAP_HOME="$(ls $0 | rev | cut -d "/" -f2- | rev)/.."
source $DAP_HOME/config/dap.config

TOKEN=$(kubectl -n kube-system describe secret default| awk '$1=="token:"{print $2}')
kubectl config set-credentials kubernetes-admin --token="${TOKEN}"
kubectl apply -f $DAP_HOME/bin/k8sdashboard.yaml
kubectl proxy &> /dev/null &
echo "Admin token: $TOKEN"
