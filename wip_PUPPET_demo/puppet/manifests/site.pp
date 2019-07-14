node default {
}

# Sample node with hardcode secret
node /^dev-webapp.*$/ {
  $mysecretkey  = Sensitive('H@rdC0de$e(e1')
  $mydbpassword  = Sensitive('puff, the magic dragon')

  notify { "*** Secret key - encrypted:  ${mysecretkey} ": }
  notify { "*** Secret key - unencrypted:  ${mysecretkey.unwrap} ": }
  notify { "*** DB Password - encrypted:  ${mydbpassword} ": }
  notify { "*** DB Password - unencrypted:  ${mydbpassword.unwrap} ": }
  notify { "******* Writing secret key to file /etc/mysecretkey ******": }

  file { '/etc/mysecretkey':
    ensure => file,
    content => Sensitive($mysecretkey),
    mode => '0600'
  }
}

# Sample node with secret store in conjur
node /^prod-webapp.*$/ {
  require conjur

  $mysecretkey = conjur::secret('puppetdemo/secretkey')
  $mydbpassword = conjur::secret('puppetdemo/dbpassword')

  notify { "*** Secret key - encrypted:  ${mysecretkey} ": }
  notify { "*** Secret key - unencrypted:  ${mysecretkey.unwrap} ": }
  notify { "*** DB Password - encrypted:  ${mydbpassword} ": }
  notify { "*** DB Password - unencrypted:  ${mydbpassword.unwrap} ": }
  notify { "******* Writing secret key to file /etc/mysecretkey ******": }

  file { '/etc/mysecretkey':
    ensure => file,
    content => Sensitive($mysecretkey),
    mode => '0600'
  }
}
