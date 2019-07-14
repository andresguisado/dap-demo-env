#!/bin/bash 
. utils.sh
# finds pod matching pod_name_substr and follows the secretless container log
pod_name_substr=test-app-secretless
set_namespace $TEST_APP_NAMESPACE_NAME
app_pod=$($cli get pods | grep "Running" | grep $pod_name_substr | awk '{print $1}')
$cli logs $app_pod -c secretless -f
