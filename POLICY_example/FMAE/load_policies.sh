#!/bin/bash
CLI=oc
CONJUR_CLI=conjur-cli

filelist=$(ls *.yml)
for i in $filelist; do
  $CLI cp $i $CONJUR_CLI:/policy
done

# apply global/root policies
$CLI exec $CONJUR_CLI bash -c "conjur policy load root /policy/root.yml"
$CLI exec $CONJUR_CLI bash -c "conjur policy load root /policy/users.yml"

# apply dev apps policies
$CLI exec $CONJUR_CLI bash -c "conjur policy load dev /policy/app1.yml"
$CLI exec $CONJUR_CLI bash -c "conjur policy load dev /policy/app2.yml"

# apply test apps policies
$CLI exec $CONJUR_CLI bash -c "conjur policy load test /policy/app1.yml"
$CLI exec $CONJUR_CLI bash -c "conjur policy load test /policy/app2.yml"

# apply prod apps policies
$CLI exec $CONJUR_CLI bash -c "conjur policy load prod /policy/app1.yml"
$CLI exec $CONJUR_CLI bash -c "conjur policy load prod /policy/app2.yml"

# apply policies for common resources
$CLI exec $CONJUR_CLI bash -c "conjur policy load root /policy/common-resources.yml"
