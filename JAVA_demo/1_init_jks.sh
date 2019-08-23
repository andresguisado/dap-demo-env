#!/bin/bash 
CERT_FILE=../k8s-kube/conjur-cache/conjur-dev.pem
echo
echo "		App expects keystore password to be 'changeit'"
echo
keytool -importcert -trustcacerts -file $CERT_FILE -keystore conjur.jks
