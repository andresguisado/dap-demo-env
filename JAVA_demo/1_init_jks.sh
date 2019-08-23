#!/bin/bash -x
CERT_FILE=../k8s-kube/conjur-cache/conjur-dev.pem
keytool -importcert -trustcacerts -file $CERT_FILE -keystore conjur.jks
