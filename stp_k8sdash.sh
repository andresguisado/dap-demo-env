#!/bin/bash
kubectl delete -f ./k8sdashboard.yaml
kill -9 $(ps -ax | grep "kubectl proxy" | awk '{print $1}')
