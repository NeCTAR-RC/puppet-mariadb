class mariadb::repo::debian {
  $os = downcase($facts['os']['name'])

  include ::mariadb
  include ::apt

  apt::pin { 'apt_mariadb':
    originator => 'mariadb',
    priority   => 1001,
  }

  apt::source { 'mariadb':
    location => "${::mariadb::mirror}/repo/${::mariadb::version}/${os}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main',
    require  => [
      Apt::Pin['apt_mariadb'],
      Apt::Key['mariadb']
    ],
    notify   => Exec['apt_update'],
  }

  apt::key { 'mariadb':
    id     => '177F4010FE56CA3336300305F1656F24C74CD1D8',
    source => 'https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY',
  }

  Class['apt::update'] -> Package <| tag == 'mariadb' |>

}
