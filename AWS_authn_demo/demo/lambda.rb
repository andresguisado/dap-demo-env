#!/usr/bin/env ruby

require 'aws-sdk-core'
require 'aws-sigv4'
require 'conjur-api'

# Conjur identity
CONJUR_AUTHN_LOGIN = "host/cust-portal/313705343335/EC2SecretsAccess"
# Conjur var to retrieve
VAR_ID = "cust-portal/database/password"

# setup Conjur configuration object
Conjur.configuration.account = "dev"
Conjur.configuration.appliance_url = "https://<ec2-instance-DNS>
Conjur.configuration.authn_url = "#{Conjur.configuration.appliance_url}/authn-iam/dev"
Conjur.configuration.cert_file = "/home/ubuntu/conjur-etc/conjur-$CONJUR_ACCOUNT.pem"
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
