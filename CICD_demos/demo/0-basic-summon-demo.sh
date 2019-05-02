#!/bin/bash
if [[ "$1" == "" ]]; then
	echo "need to specify an environment (dev, test or prod)"
	exit 01
fi
clear
echo "Here is the contents of secrets.yml:"
cat secrets.yml
echo
echo "Here are the secrets Summon retrieves for the $1 environment:"
summon -e $1 ./secrets_echo.sh
echo
echo "The subdirectories show how Ansible, Chef and Terraform can pull secrets from CyberArk."
echo
