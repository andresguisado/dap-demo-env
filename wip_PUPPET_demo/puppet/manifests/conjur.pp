class { conjur:
  account	     => 'dev',
  appliance_url      => 'https://conjur-master:30443/api',
  authn_login        => "host/app-${::trusted['hostname']}",
  host_factory_token => Sensitive('13nemvs1y3dna92fpj2nnaj6me2mx4m6g1j6s5fd3smbyj1ck23vt'),
  ssl_certificate    => file('/etc/conjur.pem'),
  version            => 5,
}

