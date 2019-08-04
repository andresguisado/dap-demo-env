class { conjur:
  account	     => 'dev',
  appliance_url      => 'https://conjur-master:30443/api',
  authn_login        => "host/app-${::trusted['hostname']}",
  host_factory_token => Sensitive('28d6eyp3gm0cpt22eexqbvrsbey7cybk63e067c62d895kx3bpke8'),
  ssl_certificate    => file('/etc/conjur.pem'),
  version            => 5,
}

