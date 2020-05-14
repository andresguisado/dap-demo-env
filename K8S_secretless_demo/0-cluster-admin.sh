#!/bin/bash +e
source ../config/dap.config
source ../config/utils.sh

login_as $CLUSTER_ADMIN_USERNAME

echo "Creating namespace & RBAC role bindings..."

sed -e "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g"	\
     ./manifests/templates/dap-user-rbac.template.yaml           	\
    | sed -e "s#{{ CONJUR_NAMESPACE_NAME }}#$CONJUR_NAMESPACE_NAME#g" 	\
    | sed -e "s#{{ DEVELOPER_USERNAME }}#$DEVELOPER_USERNAME#g" 	\
    > ./manifests/dap-user-rbac-$TEST_APP_NAMESPACE_NAME.yaml

$CLI apply -f ./manifests/dap-user-rbac-$TEST_APP_NAMESPACE_NAME.yaml

if [[ $PLATFORM = openshift ]]; then
    # Stateful database pods need to be able to modify their internal state
    $CLI adm policy add-scc-to-user anyuid -z secretless-stateful-app -n $TEST_APP_NAMESPACE_NAME
fi

echo "User RBAC manifest applied."
