#!/usr/bin/env ruby

require 'aws-sdk-core'
require 'aws-sigv4'
require 'conjur-api'

# URL hostname should be Public DNS where Conjur is running
CONJUR_MASTER_HOSTNAME = "ec2-13-59-161-219.us-east-2.compute.amazonaws.com"
CONJUR_APPLIANCE_URL = "https://#{CONJUR_MASTER_HOSTNAME}"
# Service ID specifies which Conjur IAM authenticator to use
AUTHN_IAM_SERVICE_ID = "dev"
# Login is host identity specified in Conjur policy
APPLICATION_NAME = "cust-portal"
AWS_ACCOUNT_NUMBER = "313705343335"
AWS_IAM_ROLE = "EC2SecretsAccess"
CONJUR_AUTHN_LOGIN = "host/#{APPLICATION_NAME}/#{AWS_ACCOUNT_NUMBER}/#{AWS_IAM_ROLE}"
CONJUR_ACCOUNT = "dev"
CONJUR_CERT_FILE = "/home/ubuntu/conjur-#{CONJUR_ACCOUNT}.pem"

# Conjur var to retrieve
VAR_ID = "cust-portal/database/password"

# setup Conjur configuration object
Conjur.configuration.account = "dev"
Conjur.configuration.appliance_url = "https://#{CONJUR_MASTER_HOSTNAME}"
Conjur.configuration.authn_url = "#{Conjur.configuration.appliance_url}/authn-iam/#{AUTHN_IAM_SERVICE_ID}"
Conjur.configuration.cert_file = "#{CONJUR_CERT_FILE}"
Conjur.configuration.apply_cert_config!

# Make a signed request to STS to get an authorization header
header = Aws::Sigv4::Signer.new(
  service: 'sts',
  region: 'us-east-1',
  credentials_provider: Aws::InstanceProfileCredentials.new
).sign_request(
  http_method: 'GET',
  url: 'https://sts.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15'
).headers

# Authenticate Conjur host identity using signed header in json format
conjur = Conjur::API.new_from_key("#{CONJUR_AUTHN_LOGIN}", header.to_json)
# Get access token
conjur.token

# Use the cached token to get the secrets
variable_value = conjur.resource("#{Conjur.configuration.account}:variable:#{VAR_ID}").value
print "#{variable_value}"
