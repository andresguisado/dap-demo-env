#!/bin/bash
# Passes username/apikey to the `authenticate` method, then base64 encodes the token
# This will return the value that needs to be put in the Authorization header.
# This example is bypassing SSL validation. Use -cacert to pass the certificate if you wish to perform SSL validation
curl -k --data $api_key "https://master1.nate.lab/authn/cybr/admin/authenticate" | base64 | tr -d '\r\n'
