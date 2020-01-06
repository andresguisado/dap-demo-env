class { conjur:
  account	     => 'dev',
  appliance_url      => 'https://conjur-master-vbx:30443/api',
  authn_login        => "host/${::trusted['hostname']}",
  host_factory_token => Sensitive('3mbxzzc2p08hqatpd1mwq14zw2132bkc53kr11fs9sj6fq3xj7j4y'),
  ssl_certificate    => file('/etc/conjur.pem'),
  version            => 5,
}

