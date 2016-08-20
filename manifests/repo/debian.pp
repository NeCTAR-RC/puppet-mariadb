class mariadb::repo::debian {
  $version = $mariadb::repo_version
  $mirror = $mariadb::mirror

  apt::source { 'mariadb':
    location => "${mirror}/repo/${version}/${operatingsystem}",
    release  => $::lsbdistcodename,
    repos    => 'main',
  }

  if $::http_proxy and $::rfc1918_gateway == 'true' {
    $key_options = "http-proxy=${::http_proxy}"
  } else {
    $key_options = false
  }

  apt::key { 'mariadb-1':
    id      => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
    server  => 'pgp.mit.edu',
    options => $key_options,
  }

  apt::key { 'mariadb-2':
    id      => '177F4010FE56CA3336300305F1656F24C74CD1D8',
    server  => 'keyserver.ubuntu.com',
    options => $key_options,
  }

}
