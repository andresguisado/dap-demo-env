#!/bin/bash
                # set DAP_HOME to parent directory of this script
DAP_HOME="$(ls $0 | rev | cut -d "/" -f2- | rev)/.."
source $DAP_HOME/config/dap.config
kubectl delete -f $DAP_HOME/bin/k8sdashboard.yaml
