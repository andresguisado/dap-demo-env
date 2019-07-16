#!/bin/bash 
. utils.sh
# Follow the app pod's secretless container log
POD_NAME_SUBSTR=test-app-secretless
CONT_NAME=secretless
set_namespace $TEST_APP_NAMESPACE_NAME
app_pod=$($cli get pods | grep "Running" | grep $POD_NAME_SUBSTR | awk '{print $1}')
$cli logs $app_pod -c $CONT_NAME -f
