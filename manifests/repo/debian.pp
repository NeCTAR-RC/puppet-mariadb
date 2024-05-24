class mariadb::repo::debian {
  $os = downcase($::operatingsystem)

  include ::mariadb
  include ::apt

  apt::pin { 'apt_mariadb':
    originator => 'mariadb',
    priority   => 1001,
  }
  -> apt::source { 'mariadb':
    location => "${::mariadb::mirror}/repo/${::mariadb::version}/${os}",
    release  => $::lsbdistcodename,
    repos    => 'main',
  }

  apt::key { 'mariadb-1':
    id      => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
    server  => 'keyserver.ubuntu.com',
  }
  apt::key { 'mariadb-2':
    id      => '177F4010FE56CA3336300305F1656F24C74CD1D8',
    server  => 'keyserver.ubuntu.com',
  }

  Apt::Source <| title == 'mariadb' |> -> Class['apt::update'] -> Package <| tag == 'mariadb' |>

}
