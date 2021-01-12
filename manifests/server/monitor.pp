class mariadb::server::monitor (
  $mariadb_monitor_username,
  $mariadb_monitor_password,
  $mariadb_monitor_hostname
) {

  Class['mariadb::server'] -> Class['mariadb::server::monitor']

  database_user{ "${mariadb_monitor_username}@${mariadb_monitor_hostname}":
    ensure        => present,
    password_hash => mysql_password($mariadb_monitor_password),
  }

  mysql_grant { "${mariadb_monitor_username}@${mariadb_monitor_hostname}/*.*":
    user       => "${mariadb_monitor_username}@${mariadb_monitor_hostname}",
    table      => '*.*',
    privileges => [ 'PROCESS', 'SUPER' ],
    require    => Database_user["${mariadb_monitor_username}@${mariadb_monitor_hostname}"],
  }

}
