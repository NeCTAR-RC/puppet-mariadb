# Class: mariadb::cluster
#
# manages the installation of the mariadb server.  manages the package, service,
# my.cnf
#
# Parameters:
#   [*package_names*]         - array of server package names to install
#   [*package_ensure*]        - ensure value for packages
#   [*service_name*]          - name of service
#   [*client_package_names*]  - array of client package names
#   [*client_package_ensure*] - ensure value for the client packages
#   [*config_hash*]           - hash of config parameters that need to be set.
#   [*enabled*]               - whether or not to enable the cluster
#   [*manage_service*]        - hash of config parameters that need to be set.
#   [*cluster_servers*]       - array of hosts in the galera cluster
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::cluster (
  $package_names    = $mariadb::params::cluster_package_names,
  $package_ensure   = $mariadb::params::cluster_package_ensure,
  $galera_name      = $mariadb::params::galera_package_name,
  $galera_ensure    = $mariadb::params::galera_package_ensure,
  $service_name     = $mariadb::params::service_name,
  $config_hash      = {},
  $enabled          = true,
  $cluster_servers  = undef,
) inherits mariadb::params {

  if $cluster_servers == undef {
    fail("Must provide an array of MariaDB Galera cluster hosts")
  }

  package { $galera_name:
    ensure => $galera_ensure,
  }

  class { 'mariadb::server':
    package_names    => $package_names,
    package_ensure   => $package_ensure,
    service_name     => $service_name,
    config_hash      => $config_hash,
    enabled          => $enabled,
    manage_service   => false,
  }

  # Find the next server in the list as a peer to sync with
  $cluster_peer = inline_template("<% (0..cluster_servers.length).each do |i|; if cluster_servers[i] == ipaddress; if (i+1) == cluster_servers.length %><%= cluster_servers[0] %><% else %><%= cluster_servers[i+1] %><% end; end; end %>")

  file { '/etc/mysql/conf.d/mariadb.cnf':
    content => template('mariadb/mariadb.cnf.erb'),
    require => Class['mariadb::server'],
  }

}
