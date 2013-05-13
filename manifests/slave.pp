class mariadb::slave inherits mariadb {

  file { '/etc/mysql/conf.d/replication.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/mariadb/slave-replication.cnf',
    notify  => Service['mysql'],
    require => Package['mariadb-galera-server'],
  }

  nagios::nrpe::service {
    'check_mysqld_slave':
      servicegroups => 'databases',
      check_command  => '/usr/lib/nagios/plugins/check_mysql -S',
    }
}
