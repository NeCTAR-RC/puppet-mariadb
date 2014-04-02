class mariadb::repos {

  apt::source { 'mariadb':
    location    => 'http://mirror.aarnet.edu.au/pub/MariaDB/repo/5.5/ubuntu',
    repos       => 'main',
    key         => '1BB943DB',
  }

}
