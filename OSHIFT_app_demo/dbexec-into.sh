#!/bin/bash 
. utils.sh
# finds pod matching pod_name_substr and follows the secretless container log
if [[ $1 == pg ]]; then
  pod_name_substr=postgres-db
elif [[ $1 == ms ]]; then
  pod_name_substr=mysql-db
else
  echo "Usage: $0 [ pg | ms ]"
  exit -1
fi

set_namespace $TEST_APP_NAMESPACE_NAME
app_pod=$($cli get pods | grep "Running" | grep $pod_name_substr | awk '{print $1}')
$cli exec -it $app_pod -- bash
