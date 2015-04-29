class mariadb::repo::debian {
  $version = $mariadb::repo_version

  apt::source { 'mariadb':
    location => "http://mirror.aarnet.edu.au/pub/MariaDB/repo/${version}/ubuntu",
    repos    => 'main',
  }

  if $::http_proxy and $::rfc1918_gateway == 'true' {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = false
  }

  apt::key { 'mariadb':
    key         => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
    key_server  => 'pgp.mit.edu',
    key_options => $key_options,
  }
}
