define mariadb::user (
  $user,
  $password,
  $database,
  $grant='read-only',
  $access='localhost') {

  include mariadb
  $mysql_root_password = $mariadb::mysql_root_password

  case $grant {
    'read-only': {
      $mysql_grant = 'SELECT'
    }
    'read-write': {
      $mysql_grant = 'ALL'
    }
  }

  exec { "create-mysql-${name}-user":
    command => "mysql -u root -p${mysql_root_password} -e \"GRANT ${mysql_grant} ON ${database}.* TO '${user}'@'localhost' IDENTIFIED BY '${password}';\"",
    path    => '/bin:/usr/bin',
    unless  => "mysql -u${user} -p${password} -eexit",
    #require => Service['mysql'],
  }

  if $access != 'localhost' {
    exec { "create-mysql-${name}-user-remote":
      command => "mysql -u root -p${mysql_root_password} -e \"GRANT ${mysql_grant} ON ${database}.* TO '${user}'@'${access}' IDENTIFIED BY '${password}';\"",
      path    => '/bin:/usr/bin',
      unless  => "mysql -u${user} -p${password} -h ${ipaddress} -eexit",
      #require => Service['mysql'],
    }
  }
}
