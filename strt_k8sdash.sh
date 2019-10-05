#!/bin/bash
TOKEN=$(kubectl -n kube-system describe secret default| awk '$1=="token:"{print $2}')
kubectl config set-credentials kubernetes-admin --token="${TOKEN}"
kubectl create -f ./k8sdashboard.yaml
kubectl proxy &> /dev/null &
echo "Admin token: $TOKEN"
