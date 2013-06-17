class mariadb::cluster::auth (
  $wsrep_sst_password,
  $wsrep_sst_user = 'root',) inherits mariadb::params {
  require 'mariadb'
  require 'mariadb::server'

  database_user { "${wsrep_sst_user}@%":
    ensure        => present,
    password_hash => mysql_password($wsrep_sst_password),
    require       => Package[$mariadb::params::cluster_package_names],
  }

  database_grant { "${wsrep_sst_user}@%":
    privileges => ['all'],
    require    => Package[$mariadb::params::cluster_package_names],
  }

}

