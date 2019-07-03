# Sets up yum repo for mariaDB
class mariadb::repo::redhat {

  include ::mariadb

  yumrepo { 'mariadb':
    baseurl  => "${::mariadb::mirror}/${::mariadb::version}/rhel\$releasever-amd64/",
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => "${mirror}/RPM-GPG-KEY-MariaDB",
    descr    => 'MariaDB Yum Repository',
  }

}
