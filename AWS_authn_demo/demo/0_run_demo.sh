#!/bin/bash
source ./demo.config
summon -p ./summon-aws.rb ./echo_secrets.sh
summon ./echo_secrets.sh
