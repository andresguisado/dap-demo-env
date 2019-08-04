#!/bin/bash -e
cp $CACHE_DIR/conjur*.pem ./conjur.pem
htpasswd -bc .htpasswd demo demo
docker build -t nginx-ocp:latest .
rm .htpasswd
