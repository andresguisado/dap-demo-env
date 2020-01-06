#!/bin/bash
source ../config/dap.config
source ../config/utils.sh

echo "Creating namespace & RBAC role bindings..."

login_as $CLUSTER_ADMIN_USERNAME

if [[ $PLATFORM == openshift \
	&& "$($CLI get user $DEVELOPER_USERNAME --no-headers --ignore-not-found)" == "" ]]; then
  $CLI create user $DEVELOPER_USERNAME
  $CLI create useridentitymapping anypassword:$DEVELOPER_USERNAME $DEVELOPER_USERNAME
fi

sed -e "s#{{ TEST_APP_NAMESPACE_NAME }}#$TEST_APP_NAMESPACE_NAME#g"   \
     ./manifests/templates/dap-user-rbac.template.yaml           |
    sed -e "s#{{ CONJUR_NAMESPACE_NAME }}#$CONJUR_NAMESPACE_NAME#g" |
    sed -e "s#{{ DEVELOPER_USERNAME }}#$DEVELOPER_USERNAME#g" \
    > ./manifests/dap-user-rbac-$TEST_APP_NAMESPACE_NAME.yaml

$CLI apply -f ./manifests/dap-user-rbac-$TEST_APP_NAMESPACE_NAME.yaml

echo "User RBAC manifest applied."