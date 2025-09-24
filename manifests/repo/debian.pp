class mariadb::repo::debian (
  String $key_id     = '177F4010FE56CA3336300305F1656F24C74CD1D8',
  String $key_source = 'https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY',
){
  $os = downcase($facts['os']['name'])

  include mariadb
  include apt

  apt::source { 'mariadb':
    location => "${::mariadb::mirror}/repo/${::mariadb::version}/${os}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main',
    pin      => {
      originator => 'mariadb',
      priority   =>  1001,
    },
    key      => {
      id     => $key_id,
      source => $key_source,
    },
    notify   => Exec['apt_update'],
  }

  Class['apt::update'] -> Package <| tag == 'mariadb' |>

}
