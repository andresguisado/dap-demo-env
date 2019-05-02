#!/bin/bash 
set -eo pipefail
export ANSIBLE_MODULE=ping
export ENV=prod
export USER_NAME=docker
summon ./ansssh_echo.sh $ANSIBLE_MODULE $ENV
