# Class: mariadb::cluster
#
# manages the installation of the mariadb server.  manages the package, service,
# my.cnf
#
# Parameters:
#   [*wsrep_sst_password*]
#     Password for the replication user.
#   [*cluster_servers*]
#     Array of hosts in the galera cluster. Can be specified as names
#     or IP addresses.
#   [*cluster_iface*]
#     The host interface that the cluster will communicate with.
#   [*wsrep_sst_user*]
#     The replication user name.
#   [*wsrep_cluster_name*]
#     The unique name for the cluster.
#   [*status_user*]
#     The cluster status user name.
#   [*wsrep_sst_method*]
#     The method to use for replication.
#   [*wsrep_slave_threads*]
#     Number of threads to use for replication.
#   [*package_names*]
#     Array of names of the mariadb server packages.
#   [*package_ensure*]
#     Ensure value for the server packages. Set to `present` or a version number.
#     If setting a version number see note below on `repo_version`. Ex.
#     '5.5.37'.
#   [*galera_name*]
#     The galera package name
#   [*galera_ensure*]
#     The galera package ensure value.
#   [*status_password*]
#     The password for the status user.
#   [*repo_version*]
#     Sets the version string for the repo URL. For Debian-based systems a
#     'major.minor' version is expected. Ex. '5.5'. Set a more specific
#     version using `package_ensure` parameter. For RedHat-based systems a
#     full version is required. Ex. '5.5.37'. This is due to the way the
#     yum package repo is configured.
#   [*config_hash*]
#     hash of config parameters that need to be set.
#   [*enabled*]
#     If true, enable the service to start on boot.
#   [*single_cluster_peer*]
#     If true, configure each node to sync with only one other node. Sets
#     `wsrep_cluster_address = 'gcomm://192.168.0.1'`. If false,
#     sets `wsrep_cluster_address = 'gcomm://192.168.0.1,192.168.0.2,192.168.0.3'`,
#     etc. based on number of nodes and the IP/hostname as set in 
#     `cluster_servers`.
#   [*manage_status*]
#     If true, manage the status user and status script.
#   [*manage_repo*]
#     If true, manage the yum or apt repo.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::cluster (
  $wsrep_sst_password,
  $cluster_servers,
  $cluster_iface           = 'eth0',
  $wsrep_sst_user          = 'root',
  $wsrep_cluster_name      = 'my_wsrep_cluster',
  $status_user             = 'clusterstatus',
  $wsrep_sst_method        = 'mysqldump',
  $wsrep_slave_threads     = $mariadb::params::slave_threads,
  $package_names           = $mariadb::params::cluster_package_names,
  $package_ensure          = $mariadb::params::cluster_package_ensure,
  $galera_name             = $mariadb::params::galera_package_name,
  $galera_ensure           = $mariadb::params::cluster_package_ensure,
  $debiansysmaint_password = undef,
  $status_password         = undef,
  $repo_version            = $mariadb::params::repo_version,
  $config_hash             = {},
  $enabled                 = true,
  $single_cluster_peer     = true,
  $manage_status           = true,
  $manage_repo             = true,
) inherits mariadb::params {

  package { $galera_name:
    ensure => $galera_ensure,
  }

  class { 'mariadb::server':
    package_names           => $package_names,
    package_ensure          => $package_ensure,
    debiansysmaint_password => $debiansysmaint_password,
    repo_version            => $repo_version,
    manage_repo             => $manage_repo,
    config_hash             => $config_hash,
    enabled                 => $enabled,
  }

  class { 'mariadb::cluster::auth':
    wsrep_sst_user     => $wsrep_sst_user,
    wsrep_sst_password => $wsrep_sst_password,
  }

  if $manage_status == true {
    if $status_password == undef {
      fail('Must specify status_password to manage cluster status')
    }

    class { 'mariadb::cluster::status':
      status_user     => $status_user,
      status_password => $status_password,
    }
  }

  # Find the next server in the list as a peer to sync with
  if $single_cluster_peer == true {
    $cluster_peer = inline_template("<% (0..@cluster_servers.length).each do |i|; if @cluster_servers[i] == @ipaddress_${cluster_iface}; if (i+1) == @cluster_servers.length %><%= @cluster_servers[0] %><% else %><%= @cluster_servers[i+1] %><% end; end; end %>")
  } else {
    $cluster_peer = join($cluster_servers,',')
  }

  $wsrep_sst_auth = "${wsrep_sst_user}:${wsrep_sst_password}"

  file { "${mariadb::params::config_dir}/galera_replication.cnf":
    content => template('mariadb/galera_replication.cnf.erb'),
    require => Class['mariadb::server'],
  }

  if $wsrep_sst_method == 'xtrabackup' or $wsrep_sst_method == 'xtrabackup-v2' {
    ensure_packages(['percona-xtrabackup'])
  }

}
