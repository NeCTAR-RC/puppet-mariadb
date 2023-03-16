class mariadb::server::debiansysmaint (
  $password,
) {

  database_user { 'debian-sys-maint@localhost':
    ensure        => present,
    password_hash => mysql_password($password),
    require       => Class['mariadb::server'],
  }

  mysql_grant { 'debian-sys-maint@localhost/*.*':
    user       => 'debian-sys-maint@localhost',
    table      => '*.*',
    privileges => [ 'all' ],
    require    => Database_user['debian-sys-maint@localhost'],
  }

}
