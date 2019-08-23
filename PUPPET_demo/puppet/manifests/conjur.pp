class { conjur:
  account	     => 'dev',
  appliance_url      => 'https://conjur-master:30443/api',
  authn_login        => "host/${::trusted['hostname']}",
  host_factory_token => Sensitive('3m10tjb1hx831g34xp0ty1fq0hs43zqwqqz3jxncc61vx18kzcag5yg'),
  ssl_certificate    => file('/etc/conjur.pem'),
  version            => 5,
}

