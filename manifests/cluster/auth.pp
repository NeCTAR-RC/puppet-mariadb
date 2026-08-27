class mariadb::cluster::auth (
  Variant[String[1], Sensitive[String[1]]] $wsrep_sst_password,
  String[1] $wsrep_sst_user = 'root',
) {

  $real_wsrep_sst_password = $wsrep_sst_password.unwrap

  database_user { "${wsrep_sst_user}@%":
    ensure        => present,
    password_hash => Sensitive(mysql_password($real_wsrep_sst_password)),
    require       => Class['mariadb::server'],
  }

  mysql_grant { "${wsrep_sst_user}@%/*.*":
    user       => "${wsrep_sst_user}@%",
    table      => '*.*',
    privileges => [ 'all' ],
    require    => Database_user["${wsrep_sst_user}@%"],
  }

}
