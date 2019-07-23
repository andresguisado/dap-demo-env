class { conjur:
  account	     => 'dev',
  appliance_url      => 'https://conjur-master:30443/api',
  authn_login        => "host/app-${::trusted['hostname']}",
  host_factory_token => Sensitive('d0g9w82ah45ee27vrjmb1j8wsm2127t9jtek4bay34q7prh24sa6wv'),
  ssl_certificate    => file('/etc/conjur.pem'),
  version            => 5,
}

