# Class: mariadb::server
#
# manages the installation of the mariadb server.  manages the package, service,
# my.cnf
#
# Parameters:
#   [*package_ensure*]
#     Ensure value for the server packages. Set to `present` or a version number.
#   [*package_names*]
#     Array of names of the mariadb server packages.
#   [*service_name*]
#     Name of the mariadb service
#   [*service_provider*]
#     Service type's provider
#   [*config_hash*]
#     hash of config parameters that need to be set.
#   [*enabled*]
#     If true, enable the service to start on boot.
#   [*manage_service*]
#     If true, manage the service.
#   [*mirror*]
#     Set the URL to the download mirror (Note: All but the operatingsystem /debian|/ubuntu)
#   [*config_hash*]   - hash of config parameters that need to be set.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::server (
  $package_ensure          = $mariadb::params::server_package_ensure,
  $package_names           = undef,
  $service_name            = $mariadb::params::service_name,
  $service_provider        = $mariadb::params::service_provider,
  $debiansysmaint_password = undef,
  $config_hash             = {},
  $enabled                 = true,
  $manage_service          = true,
) inherits mariadb::params {

  include ::mariadb

  if $package_names == undef {
    $real_package_names = $::mariadb::server_package_names
  } else {
    $real_package_names = $package_names
  }

  Class['mariadb::server'] -> Class['mariadb::config']

  $config_class = { 'mariadb::config' => $config_hash }

  create_resources( 'class', $config_class )

  package { $real_package_names:
    ensure  => $package_ensure,
  }

  file { '/var/log/mysql/error.log':
    owner => mysql,
    require => Package[$real_package_names],
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  if $manage_service {
    $piddir = dirname($mariadb::params::pidfile)

    file { $piddir:
      ensure  => directory,
      owner   => 'mysql',
      group   => 'root',
      mode    => '0755',
      require => Package[$real_package_names],
    }

    -> service { 'mariadb':
      ensure   => $service_ensure,
      name     => $service_name,
      enable   => $enabled,
      require  => Package[$real_package_names],
      provider => $service_provider,
    }
  }
}
