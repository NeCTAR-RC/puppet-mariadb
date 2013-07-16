# Class: mariadb::cluster
#
# manages the installation of the mariadb server.  manages the package, service,
# my.cnf
#
# Parameters:
#   [*package_names*]         - array of server package names to install
#   [*package_ensure*]        - ensure value for packages
#   [*client_package_names*]  - array of client package names
#   [*client_package_ensure*] - ensure value for the client packages
#   [*config_hash*]           - hash of config parameters that need to be set.
#   [*net_ipaddress*]         - the ipaddres to check for master (default:
#   $::ipaddress)
#   [*enabled*]               - whether or not to enable the cluster
#   [*cluster_servers*]       - array of hosts in the galera cluster
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::cluster (
  $debiansysmaint_password,
  $wsrep_sst_password,
  $status_password,
  $cluster_master,
  $cluster_servers,
  $net_ipaddress       = $::ipaddress,
  $wsrep_sst_user      = 'root',
  $wsrep_cluster_name  = 'my_wsrep_cluster',
  $status_user         = 'clusterstatus',
  $wsrep_sst_method    = 'mysqldump',
  $wsrep_slave_threads = $mariadb::params::slave_threads,
  $package_names       = $mariadb::params::cluster_package_names,
  $package_ensure      = $mariadb::params::cluster_package_ensure,
  $galera_name         = $mariadb::params::galera_package_name,
  $galera_ensure       = $mariadb::params::galera_package_ensure,
  $config_hash         = {
  }
  ,) inherits mariadb::params {
  Class['mariadb::cluster'] -> Class['mariadb::server']

  if $cluster_servers == undef {
    fail("Must provide an array of MariaDB Galera cluster hosts")
  }

  if $wsrep_sst_method == 'rsync' and !defined(Package['rsync']) {
    package { 'rsync': }
  }

  package { $galera_name: ensure => $galera_ensure, }

  class {
    'mariadb::server':
      package_names           => $package_names,
      package_ensure          => $package_ensure,
      debiansysmaint_password => $debiansysmaint_password,
      config_hash             => $config_hash,
      enabled                 => $enabled;

    'mariadb::cluster::auth':
      wsrep_sst_user     => $wsrep_sst_user,
      wsrep_sst_password => $wsrep_sst_password;

    'mariadb::cluster::status':
      status_user     => $status_user,
      status_password => $status_password,
  }

  # Find the next server in the list as a peer to sync with
  # $cluster_peer = inline_template("<% (0..cluster_servers.length).each do |i|;
  # if cluster_servers[i] == cluster_master; if (i+1) == cluster_servers.length
  # %><%= cluster_servers[0] %><% else %><%= cluster_servers[i+1] %><% end; end;
  # end %>"
  # $cluster_peer = inline_template("<% [cluster_servers].flatten.each do
  # |addr|; if addr == cluster_master; %><%= '' %><% else %><%= cluster_master
  # %><% end; end %>"
  #)
  if $::ipaddress_private == $cluster_master {
    $cluster_peer = ''
  } else {
    $cluster_peer = $cluster_master
  }
  $wsrep_sst_auth = "${wsrep_sst_user}:${wsrep_sst_password}"

  file { '/etc/mysql/conf.d/galera_replication.cnf': content => template('mariadb/galera_replication.cnf.erb'
    ), }

  if $wsrep_sst_method == 'xtrabackup' {
    package { 'percona-xtrabackup': ensure => 'installed' }
  }

}
