class mariadb::repo::redhat {
  $version = $mariadb::repo_version

  yumrepo { 'mariadb':
    baseurl         => "http://yum.mariadb.org/${version}/rhel\$releasever-amd64/",
    enabled         => '1',
    gpgcheck        => '1',
    gpgkey          => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
    descr           => 'MariaDB Yum Repository',
  }

}
