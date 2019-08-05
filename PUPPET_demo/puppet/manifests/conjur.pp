class { conjur:
  account	     => 'dev',
  appliance_url      => 'https://conjur-master:30443/api',
  authn_login        => "host/${::trusted['hostname']}.localdomain",
  host_factory_token => Sensitive('98m5491xxafna2cceqm61rpcxja35nam3z3nfc1kb3rr0wc632mzk0h'),
  ssl_certificate    => file('/etc/conjur.pem'),
  version            => 5,
}

