#!/bin/bash -ex
cp $MASTER_CERT_FILE ./conjur.pem
htpasswd -bc .htpasswd demo demo
docker build -t nginx-secretless:latest .
rm .htpasswd
