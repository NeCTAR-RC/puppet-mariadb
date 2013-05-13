define mariadb::user_nopass (
  $user,
  $access='localhost') {

  include mariadb
  $mysql_root_password = $mariadb::mysql_root_password

  exec { "create-mysql-${name}-user":
    command => "mysql -u root -p${mysql_root_password} -D mysql -e \"INSERT INTO user (User,Host) values ('${user}','localhost'); FLUSH PRIVILEGES;\"",
    path    => '/bin:/usr/bin',
    unless  => "mysql -u${user} -eexit",
    #require => Service['mysql'],
  }

  if $access != 'localhost' {

    exec { "create-mysql-${name}-user-remote":
      command => "mysql -u root -p${mysql_root_password} -D mysql -e \"INSERT INTO user (User,Host) values ('${user}','${access}'); FLUSH PRIVILEGES;\"",
      path    => '/bin:/usr/bin',
      unless  => "mysql -u${user} -h ${ipaddress} -eexit",
      #require => Service['mysql'],
    }
  }
}
