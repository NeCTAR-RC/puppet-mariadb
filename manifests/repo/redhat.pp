class mariadb::repo::redhat (
   $repo_version = $mariadb::params::repo_version,
   $mirror = $mariadb::params::default_mirror
){

  yumrepo { 'mariadb':
    baseurl         => "${mirror}/${repo_version}/rhel\$releasever-amd64/",
    enabled         => '1',
    gpgcheck        => '1',
    gpgkey          => "${mirror}/RPM-GPG-KEY-MariaDB",
    descr           => 'MariaDB Yum Repository',
  }

}
