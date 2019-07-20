#!/bin/bash 
. utils.sh

if [[ $1 != pg && $1 != ms ]]; then
  echo "Usage: $0 [ pg | ms ]"
  exit -1
fi
DB=$1

# finds pod matching pod_name_substr and follows the secretless container log
if [[ $DB == pg ]]; then
  pod_name_substr=postgres-db
else
  pod_name_substr=mysql-db
fi

set_namespace $TEST_APP_NAMESPACE_NAME
app_pod=$($cli get pods | grep "Running" | grep $pod_name_substr | awk '{print $1}')
if [[ $PLATFORM == openshift ]]; then
  case $DB in
    pg )
      $cli exec -it $app_pod -- bash -c "tail -f /var/lib/pgsql/data/userdata/pg_log/postgresql-???.log"
      ;;
    ms )
      $cli exec -it $app_pod -- bash -c "tail -f /var/lib/mysql/mysql.log"
      ;;
   esac
fi
