class mariadb::repo {

  apt::source { 'mariadb':
    location => 'http://mirror.aarnet.edu.au/pub/MariaDB/repo/5.5/ubuntu',
    repos    => 'main',
  }

  $key_options = $::rfc1918_gateway ? {
    'true'  => "http-proxy=http://${::http_proxy_server}:${::http_proxy_port}",
    default => false,
  }

  apt::key { 'mariadb':
    key         => '1BB943DB',
    key_server  => 'pgp.mit.edu',
    key_options => $key_options,
  }
}
