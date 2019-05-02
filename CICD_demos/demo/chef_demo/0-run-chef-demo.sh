#!/bin/bash
if [[ $# != 1 ]]; then
  echo "Provide dev, test or prod to specify environment."
  exit -1
fi
clear
echo "This demo shows how a chef recipe can access secrets pulled from Conjur with Summon."
echo
echo "Here is the recipe:"
cat secrets-echo.rb
echo
set -x
summon -e $1 chef-solo secrets-echo.rb
