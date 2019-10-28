#!/bin/bash

. ../config/dap.config
. ../config/$PLATFORM.config
. ../config/utils.sh

if [[ $1 != pg && $1 != ms && $1 != http ]]; then
  echo "Watch backend server log."
  echo "Usage: $0 [ pg | ms | http ]"
  exit -1
fi
BACKEND=$1

# finds pod matching pod_name_substr and follows the secretless container log
if [[ $BACKEND == pg ]]; then
  pod_name_substr=postgres-db
elif [[ $BACKEND = ms ]]; then
  pod_name_substr=mysql-db
else
  pod_name_substr=nginx
fi

set_namespace $TEST_APP_NAMESPACE_NAME
app_pod=$($CLI get pods | grep "Running" | grep $pod_name_substr | awk '{print $1}')

if [[ $PLATFORM == openshift ]]; then
  case $BACKEND in
    pg )
      $CLI exec -it $app_pod -- bash -c "tail -f /var/lib/pgsql/data/userdata/pg_log/postgresql-???.log"
      ;;
    ms )
      $CLI exec -it $app_pod -- bash -c "tail -f /var/lib/mysql/mysql.log"
      ;;
    http )
      $CLI logs -f $app_pod
      ;;
   esac
fi

if [[ $PLATFORM = kubernetes ]]; then
  case $BACKEND in
    pg | ms )
      $CLI logs $app_pod -f
      ;;
    http )
      $CLI logs -f $app_pod
      ;;
   esac
fi
