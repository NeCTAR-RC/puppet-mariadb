class mariadb::master inherits mariadb {

  file { '/etc/mysql/conf.d/replication.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/mysql/master-replication.cnf',
    notify  => Service['mysql'],
    require => Package['mysql-server'],
  }

  exec { 'create-mysql-replication-user':
    command => "mysql -u root -p${mysql_root_password} -e \"CREATE USER '${mysql_replication_user}'@'${mysql_replication_access}' IDENTIFIED BY '${mysql_replication_password}'; GRANT REPLICATION SLAVE ON *.* TO '${mysql_replication_user}'@'${mysql_replication_access}';\"",
    path    => '/bin:/usr/bin',
    unless  => "mysql -u${mysql_replication_user} -p${mysql_replication_password} -h ${ipaddress}",
    require => Service['mysql'],
  }
}
