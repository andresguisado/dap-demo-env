#!/bin/bash

main() {
  if [ $# != 1 ]; then
    echo "Usage: $0 <conjur-appliance-url>"
    exit -1
  fi
  CONJUR_APPLIANCE_URL=$1

  CONJUR_AUTHN_LOGIN=admin
  CONJUR_AUTHN_PASSWORD=Cyberark1
  user_authn

  CONJUR_AUTHN_LOGIN=host/client/node
  CONJUR_AUTHN_API_KEY=w3jvdkq02nmx1e0zwv931z2ccy28zczj9x2bwrfd70xj417pk0qz
  host_authn

  read -n1 -r -p "Press space to continue..." key
  echo "Exiting..."
}

################
user_authn() {
  CONJUR_AUTHN_API_KEY=$(curl \
                            -sk \
                            --user $CONJUR_AUTHN_LOGIN:$CONJUR_AUTHN_PASSWORD \
                            $CONJUR_APPLIANCE_URL/authn/$CONJUR_ACCOUNT/login)

  response=$(curl -sk \
             --data $CONJUR_AUTHN_API_KEY \
             $CONJUR_APPLIANCE_URL/authn/$CONJUR_ACCOUNT/$CONJUR_AUTHN_LOGIN/authenticate)
        ADMIN_SESSION_TOKEN=$(echo -n $response| base64 | tr -d '\r\n')

  echo "User access token: " $ADMIN_SESSION_TOKEN
}

################
host_authn() {
  urlify $CONJUR_AUTHN_LOGIN
  CONJUR_AUTHN_LOGIN=$URLIFIED

  response=$(curl -sk \
             --data $CONJUR_AUTHN_API_KEY \
             $CONJUR_APPLIANCE_URL/authn/$CONJUR_ACCOUNT/$CONJUR_AUTHN_LOGIN/authenticate)
        ADMIN_SESSION_TOKEN=$(echo -n $response| base64 | tr -d '\r\n')

  echo "Host access token: " $ADMIN_SESSION_TOKEN
}

################
# URLIFY - url encodes input, converts ' ', '/' and ':' to hex equivalents
# in: $1 - string to convert
# out: URLIFIED - converted string in global variable
urlify() {
        local str=$1; shift
        str=$(echo $str | sed 's= =%20=g')
        str=$(echo $str | sed 's=/=%2F=g')
        str=$(echo $str | sed 's=:=%3A=g')
        URLIFIED=$str
}

main "$@"
