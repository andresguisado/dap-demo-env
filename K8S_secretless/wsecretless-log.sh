#!/bin/bash 
. ../config/dap.config
. ../config/$PLATFORM.config

# Follow the app pod's secretless container log
POD_NAME_SUBSTR=test-app-secretless
CONT_NAME=secretless
app_pod=$($CLI get pods -n $TEST_APP_NAMESPACE_NAME | grep "Running" | grep $POD_NAME_SUBSTR | awk '{print $1}')
$CLI logs $app_pod -c $CONT_NAME -f
