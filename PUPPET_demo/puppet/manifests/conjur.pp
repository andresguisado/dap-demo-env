class { conjur:
  account	     => 'dev',
  appliance_url      => 'https://conjur-master-mac:30443/api',
  authn_login        => "host/${::trusted['hostname']}",
  host_factory_token => Sensitive('xe2ggw34jgp31xhgryc3th6h071czakr01amsq153g8c2853f9ee3e'),
  ssl_certificate    => file('/etc/conjur.pem'),
  version            => 5,
}

