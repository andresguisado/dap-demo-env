#!/bin/bash 
if [[ $# != 3 ]]; then
  echo "Usage: $0 <host-factory> <hostname> <root-password-name>"
  exit -1
fi
host_factory=$1
new_hostname=$2
root_password_name=$3

CLI=docker
CONJUR_CLI=conjur-cli

# create new HF token & host
$CLI exec -it $CONJUR_CLI conjur authn login -u admin -p Cyberark1
hf_token=$($CLI exec -it $CONJUR_CLI bash -c "conjur hostfactory tokens create $host_factory" | jq -r .[].token)
$CLI exec -it $CONJUR_CLI conjur hostfactory hosts create $hf_token $new_hostname
$CLI exec -it $CONJUR_CLI conjur hostfactory tokens revoke $hf_token

# inject hostname and root pwd name in privilege grant, copy to cli and load
sed -e "s#{{ HOSTNAME }}#$new_hostname#g" ./priv-grant.template |
	sed -e "s#{{ VARNAME }}#$root_password_name#g" > $new_hostname.yml
$CLI cp $new_hostname.yml $CONJUR_CLI:/policy/
$CLI exec -it $CONJUR_CLI conjur policy load root /policy/$new_hostname.yml
$CLI exec -it $CONJUR_CLI rm /policy/$new_hostname.yml
rm ./$new_hostname.yml

# check that only the new host has execute permission on root password
$CLI exec -it $CONJUR_CLI conjur resource permitted_roles variable:$root_password_name execute
