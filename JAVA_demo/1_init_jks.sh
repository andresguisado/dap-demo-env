#!/bin/bash 
CONJUR_CERT_FILE=../k8s-kube/conjur-cache/conjur-dev.pem
echo
echo "		Run script expects keystore password to be 'changeit'"
echo
keytool -importcert -trustcacerts -file $CONJUR_CERT_FILE -keystore conjur.jks
