# Class: mariadb::repo::debian
#
# Sets up the apt repo for MariaDB.
#
# Parameters:
#   [*key_source*] - URL to fetch the repository GPG key from.
#
class mariadb::repo::debian (
  String $key_source = 'https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY',
) {
  $os = downcase($facts['os']['name'])

  include mariadb
  include apt

  # MariaDB Server GPG signing key
  # 177F4010FE56CA3336300305F1656F24C74CD1D8
  apt::keyring { 'mariadb.asc':
    source => $key_source,
    before => Apt::Source['mariadb'],
  }

  apt::source { 'mariadb':
    location => "${mariadb::mirror}/repo/${mariadb::version}/${os}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main',
    pin      => {
      originator => 'mariadb',
      priority   => 1001,
    },
    keyring  => '/etc/apt/keyrings/mariadb.asc',
    notify   => Exec['apt_update'],
  }

  Class['apt::update'] -> Package <| tag == 'mariadb' |>
}
