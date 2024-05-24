class mariadb::server::account_security {
  # Some installations have some default users which are not required.
  # We remove them here. You can subclass this class to overwrite this behavior.
  database_user { [ "root@${facts['networking']['fqdn']}", 'root@127.0.0.1', 'root@::1',
                    "@${facts['networking']['fqdn']}", '@localhost', '@%' ]:
    ensure  => 'absent',
    require => Class['mariadb::config'],
  }
  if ($facts['networking']['fqdn'] != $facts['networking']['hostname']) {
    database_user { ["root@${facts['networking']['hostname']}", "@${facts['networking']['hostname']}"]:
      ensure  => 'absent',
      require => Class['mariadb::config'],
    }
  }
  database { 'test':
    ensure  => 'absent',
    require => Class['mariadb::config'],
  }
}
