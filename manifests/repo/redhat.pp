# Sets up yum repo for mariaDB
class mariadb::repo::redhat {

  include ::mariadb

  yumrepo { 'mariadb':
    baseurl  => "https://archive.mariadb.org/mariadb-${::mariadb::version}/yum/centos$releasever-amd64/",
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => "https://archive.mariadb.org/PublicKey",
    descr    => 'MariaDB Yum Repository',
  }

}
