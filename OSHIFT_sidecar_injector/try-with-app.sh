#!/usr/bin/env bash
export CONJUR_VERSION="5"
export CONJUR_NAMESPACE_NAME="x"
export CONJUR_ACCOUNT="x"
export AUTHENTICATOR_ID="x"
export TEST_APP_SERVICE_ACCOUNT="x"
export TEST_APP_NAMESPACE_NAME="secretless-sidecar-test"
export containerMode="sidecar"
export CONJUR_APPLIANCE_URL="https://conjur-follower.${CONJUR_NAMESPACE_NAME}.svc.cluster.local/api"
export CONJUR_AUTHN_URL="https://conjur-follower.${CONJUR_NAMESPACE_NAME}.svc.cluster.local/api/authn-k8s/${AUTHENTICATOR_ID}"
export CONJUR_AUTHN_LOGIN=host/conjur/authn-k8s/${AUTHENTICATOR_ID}/apps/${TEST_APP_NAMESPACE_NAME}/service_account/${TEST_APP_SERVICE_ACCOUNT}
export CONJUR_SSL_CERTIFICATE="--"

kubectl delete namespace --ignore-not-found ${TEST_APP_NAMESPACE_NAME}
# create TEST_APP_NAMESPACE_NAME and label the namespace with cyberark-sidecar-injector=enabled
kubectl create namespace ${TEST_APP_NAMESPACE_NAME}
kubectl label \
  namespace ${TEST_APP_NAMESPACE_NAME} \
  cyberark-sidecar-injector=enabled
kubectl get namespace -L cyberark-sidecar-injector

# This service account maps to the Conjur identity for the pod
kubectl -n ${TEST_APP_NAMESPACE_NAME} \
create serviceaccount ${TEST_APP_SERVICE_ACCOUNT}

# Create Conjur ConfigMap
cat << EOL | kubectl -n ${TEST_APP_NAMESPACE_NAME} apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: conjur
data:
  CONJUR_ACCOUNT: "${CONJUR_ACCOUNT}"
  CONJUR_VERSION: "${CONJUR_VERSION}"
  CONJUR_APPLIANCE_URL: "${CONJUR_APPLIANCE_URL}"
  CONJUR_AUTHN_URL: "${CONJUR_AUTHN_URL}"
  CONJUR_SSL_CERTIFICATE: |
$(echo "${CONJUR_SSL_CERTIFICATE}" | awk '{ print "    " $0 }')
  CONJUR_AUTHN_LOGIN: "${CONJUR_AUTHN_LOGIN}"
EOL

# run the test app
kubectl -n ${TEST_APP_NAMESPACE_NAME} \
  delete pod \
  test-app --ignore-not-found
cat << EOF | kubectl -n ${TEST_APP_NAMESPACE_NAME} apply -f -
apiVersion: v1
kind: Pod
metadata:
  annotations:
    sidecar-injector.cyberark.com/conjurAuthConfig: conjur
    sidecar-injector.cyberark.com/conjurConnConfig: conjur
    sidecar-injector.cyberark.com/containerMode: ${containerMode}
    sidecar-injector.cyberark.com/inject: "yes"
    sidecar-injector.cyberark.com/injectType: authenticator
    sidecar-injector.cyberark.com/containerName: secretless
  labels:
    app: test-app
  name: test-app
spec:
  containers:
  - image: googlecontainer/echoserver:1.1
    name: app
    volumeMounts:
    - mountPath: /run/conjur
      name: conjur-access-token
  serviceAccountName: ${TEST_APP_SERVICE_ACCOUNT}
EOF
kubectl -n ${TEST_APP_NAMESPACE_NAME} get pods
