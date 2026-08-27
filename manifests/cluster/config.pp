# Class: mariadb::cluster::config
#
# Manages the galera replication configuration file.
#
# Parameters:
#   [*wsrep_cluster_name*]  - The unique name for the cluster.
#   [*wsrep_sst_auth*]      - Authentication string ('user:password') for
#                             state snapshot transfer.
#   [*wsrep_sst_method*]    - The method to use for replication.
#   [*wsrep_slave_threads*] - Number of threads to use for replication.
#   [*config_dir*]          - Directory the config file is created in.
#
class mariadb::cluster::config (
  String[1]            $wsrep_cluster_name,
  String[1]            $wsrep_sst_auth,
  String[1]            $wsrep_sst_method,
  Integer[1]           $wsrep_slave_threads,
  Stdlib::Absolutepath $config_dir = $mariadb::params::config_dir,
) inherits mariadb::params {
  include mariadb
  $maria_version = $mariadb::version

  file { "${config_dir}/galera_replication.cnf":
    content => template('mariadb/galera_replication.cnf.erb'),
  }
}
