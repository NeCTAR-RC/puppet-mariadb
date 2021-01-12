class mariadb::cluster::status (
  $status_user,
  $status_password,
) {

  file { '/usr/local/bin/clustercheck':
    content => template('mariadb/clustercheck.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { '/usr/local/bin/clustercheck-maintenance':
    source => 'puppet:///modules/mariadb/clustercheck-maintenance.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  augeas { 'mysqlchk':
    context => '/files/etc/services',
    changes => [
      "set /files/etc/services/service-name[port = '9200']/port 9200",
      "set /files/etc/services/service-name[port = '9200'] mysqlchk",
      "set /files/etc/services/service-name[port = '9200']/protocol tcp",
    ],
  }

  xinetd::service { 'mysqlchk':
    server     => '/usr/local/bin/clustercheck',
    port       => '9200',
    user       => 'nobody',
    flags      => 'REUSE',
    instances  => 500,
    per_source => 10,
    cps        => '100 1',
  }

  database_user { "${status_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($status_password),
    require       => Class['mariadb::server'],
  }

  mysql_grant { "${status_user}@localhost/*.*":
    user       => "${status_user}@localhost",
    table      => '*.*',
    privileges => [ 'PROCESS' ],
  }

}
