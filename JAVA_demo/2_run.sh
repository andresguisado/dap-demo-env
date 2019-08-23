#!/bin/bash

# The Java keystore is created by 1_init_jks.sh script
export JAVA_KEY_STORE_FILE=./conjur.jks
export JAVA_KEY_STORE_PASSWORD=changeit

# Conjur URL, authn creds & the variable name to retrieve.
# Note that login names and variable names must be URL encoded, e.g. '/' coded as %2F
export CONJUR_APPLIANCE_URL=https://conjur-master:30443
export CONJUR_USER=admin
export CONJUR_PASSWORD=Cyberark1
export CONJUR_AUTHN_LOGIN=host%2Fclient%2Fnode
export CONJUR_AUTHN_API_KEY=37vmfsc3s3d51x784d5yhcjxh11zn71hgwa3tr11errw0gkpwzh7
export CONJUR_VAR_ID=cicd-secrets%2Fprod-db-password

# run the app
java -jar ConjurJava.jar
