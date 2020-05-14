#!/bin/bash 
. ../config/dap.config

app_pod=$($CLI get pods -n $TEST_APP_NAMESPACE_NAME | grep "Running" | grep secretless | awk '{print $1}')
$CLI exec -it $app_pod -- bash
