#!/bin/bash -ex
cp $CONJUR_CERT_FILE ./conjur.pem
htpasswd -bc .htpasswd demo demo
docker build -t nginx-ocp:latest .
rm .htpasswd
