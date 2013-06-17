class mariadb::cluster::status (
  $status_user,
  $status_password,) inherits mariadb::params {
  file { '/usr/local/bin/clustercheck':
    content => template('mariadb/clustercheck.erb'),
    mode    => '0755',
  }

  augeas { 'mysqlchk':
    context => '/files/etc/services',
    changes => [
      "set /files/etc/services/service-name[port = '9200']/port 9200",
      "set /files/etc/services/service-name[port = '9200'] mysqlchk",
      "set /files/etc/services/service-name[port = '9200']/protocol tcp",],
  }

  xinetd::service { 'mysqlchk':
    server => '/usr/local/bin/clustercheck',
    port   => '9200',
    user   => 'nobody',
    flags  => 'REUSE',
  }

  database_user { "${status_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($status_password),
    require       => Package[$mariadb::params::cluster_package_names],
  }

  database_grant { "${status_user}@localhost":
    privileges => ['process_priv'],
    require    => Package[$mariadb::params::cluster_package_names],
  }

}

