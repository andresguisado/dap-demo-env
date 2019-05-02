#!/bin/bash
source ./aws.config

./load_policy_REST.sh root $DEMO_DIR/authn-iam.yaml
./load_policy_REST.sh root $DEMO_DIR/cust-portal.yaml
./load_policy_REST.sh root $DEMO_DIR/authn-grant.yaml
./var_value_add_REST.sh $APPLICATION_NAME/database/username OracleDBuser
./var_value_add_REST.sh $APPLICATION_NAME/database/password ueus#!9
