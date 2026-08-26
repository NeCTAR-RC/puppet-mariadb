class mariadb::server::monitor (
  $mariadb_monitor_username,
  Variant[String[1], Sensitive[String[1]]] $mariadb_monitor_password,
  $mariadb_monitor_hostname
) {

  Class['mariadb::server'] -> Class['mariadb::server::monitor']

  $real_mariadb_monitor_password = $mariadb_monitor_password.unwrap

  database_user{ "${mariadb_monitor_username}@${mariadb_monitor_hostname}":
    ensure        => present,
    password_hash => Sensitive(mysql_password($real_mariadb_monitor_password)),
  }

  mysql_grant { "${mariadb_monitor_username}@${mariadb_monitor_hostname}/*.*":
    user       => "${mariadb_monitor_username}@${mariadb_monitor_hostname}",
    table      => '*.*',
    privileges => [ 'PROCESS', 'SUPER' ],
    require    => Database_user["${mariadb_monitor_username}@${mariadb_monitor_hostname}"],
  }

}
