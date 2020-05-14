#!/bin/bash
                # set DAP_HOME to parent directory of this script
DAP_HOME="$(ls $0 | rev | cut -d "/" -f2- | rev)/.."
source $DAP_HOME/config/dap.config

export AUTHN_USERNAME=$CONJUR_ADMIN_USERNAME
export AUTHN_PASSWORD=$CONJUR_ADMIN_PASSWORD
var_get_set_REST.sh set $1 "$2"
