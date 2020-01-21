#!/bin/bash
curl -vvv -k -H "Authorization: Token token=\"$(curl -k --data $(curl -k --user admin:Cyberark1 "https://master1.nate.lab/authn/cybr/login") "https://master1.nate.lab/authn/cybr/admin/authenticate" | base64 | tr -d '\r\n')\"" -d "$(cat 01_policy.yml)" "https://master1.nate.lab/policies/cybr/policy/root"

