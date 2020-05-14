#!/bin/bash
source conjur_setup/aws.config
set -x
ssh Administrator@ubuntu@$AWS_PUB_DNS@psmphost
