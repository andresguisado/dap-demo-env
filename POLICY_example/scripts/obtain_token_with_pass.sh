#!/bin/bash
# User username/password to the `login` method to obtain API key used in the `authenticate` method, then base64 encodes the token
# This will return the value that needs to be put in the Authorization header.
curl -k --data $(curl -k --user admin:Cyberark1 "https://master1.nate.lab/authn/cybr/login") "https://master1.nate.lab/authn/cybr/admin/authenticate" | base64 | tr -d '\r\n')
