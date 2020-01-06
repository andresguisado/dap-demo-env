#!/bin/bash -x
source ./demo.config

echo "Invoking Summon provider explicitly..."
summon -p ./summon-aws.rb ./echo_secrets.sh
echo

echo "Copying Summon provider to default dir & invoking implicitly..."
sudo mkdir -p /usr/local/lib/summon
sudo cp ./summon-aws.rb /usr/local/lib/summon/
summon ./echo_secrets.sh
