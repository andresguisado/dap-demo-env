#!/bin/bash

source ../config/dap.config
source ../config/$PLATFORM.config
source ../config/utils.sh
source ./injector.config

case $1 in

  injector)
	echo "###### MutatingWebHookConfiguration ######"
	$CLI describe MutatingWebhookConfiguration
	echo
	echo "###### Injector Details ######"
	injector_pod_name=$($CLI -n $INJECTOR_NAMESPACE_NAME get pods | grep sidecar-injector | awk '{print $1}')
	$CLI -n $INJECTOR_NAMESPACE_NAME describe pod $injector_pod_name
	echo
	echo "###### Injector-enabled Namespaces ######"
	$CLI get ns -L $INJECTOR_LABEL
	;;

  *)
	echo "###### Application Details ######"
	$CLI get pods -n $INJECTED_NAMESPACE_NAME
	app_pod_name=$($CLI -n $INJECTED_NAMESPACE_NAME get pods | grep $INJECTED_APP_NAME | awk '{print $1}')
	$CLI -n $INJECTED_NAMESPACE_NAME logs $app_pod_name -c injected
	$CLI -n $INJECTED_NAMESPACE_NAME logs $app_pod_name -c app
	;;
esac
