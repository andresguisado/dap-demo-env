#!/bin/bash
CLI=docker
CONJUR_CLI=conjur-cli

filelist=$(ls *.yml)
for i in $filelist; do
  $CLI cp $i $CONJUR_CLI:/policy/
done

$CLI exec $CONJUR_CLI conjur authn login -u admin -p Cyberark1
# apply global/root policies
$CLI exec $CONJUR_CLI bash -c "conjur policy load root /policy/prod.yml"
$CLI exec $CONJUR_CLI bash -c "conjur policy load root /policy/non-prod.yml"
$CLI exec $CONJUR_CLI bash -c "conjur policy load root /policy/epv-secrets.yml"
