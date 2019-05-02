class { conjur:
  account	     => 'dev',
  appliance_url      => 'https://conjur-master:30443/api',
  authn_login        => "host/app-${::trusted['hostname']}",
  host_factory_token => Sensitive('2bfkcq4v3kc7j26pxydw17aq6an2jg7ma235g07nc3rby2303ec5try'),
  ssl_certificate    => file('/etc/conjur.pem'),
  version            => 5,
}

