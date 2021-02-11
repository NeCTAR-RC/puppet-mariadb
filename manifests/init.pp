# Class: mariadb
#
#   This class installs mariadb client software.
#
# Parameters:
#   [*package_ensure*]
#     Ensure value for the package. Set to `present` or a version number.
#     If setting a version number see note below on `version`. Ex.
#     '5.5.37'.
#   [*package_names*]
#     Array of names of the mariadb client packages.
#   [*version*]
#     Sets the version string for mariadb. For Debian-based systems a
#     'major.minor' version is expected. Ex. '5.5'. Set a more specific
#     version using `package_ensure` parameter. For RedHat-based systems a
#     full version is required. Ex. '5.5.37'. This is due to the way the
#     yum package repo is configured.
#   [*manage_repo*]
#     If true, manage the yum or apt repo.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb (
  $package_ensure = 'present',
  $version        = $mariadb::params::version,
  $manage_repo    = true,
  $mirror         = $mariadb::params::default_mirror
) inherits mariadb::params {

  case $::osfamily {
    'RedHat': {
      $server_package_names  = $mariadb::params::server_package_names
      $cluster_package_names = $mariadb::params::cluster_package_names
      $client_package_names  = $mariadb::params::client_package_names
      $galera_name           = $mariadb::params::galera_package_name
      $backup_package_name   = $mariadb::params::backup_package_name
    }
    'Debian': {
      case $version {
        '5.5': {
          $server_package_names  = $mariadb::params::server_package_names
          $cluster_package_names = $mariadb::params::cluster_package_names
          $client_package_names  = $mariadb::params::client_package_names
          $galera_name           = $mariadb::params::galera_package_name
          $backup_package_name   = $mariadb::params::backup_package_name
        }
        '10.1': {
          $server_package_names  = ['mariadb-server']
          $cluster_package_names = $server_package_names
          $client_package_names  = ['mariadb-client']
          $galera_name           = 'galera-3'
          $backup_package_name   = 'mariadb-backup-10.1'
        }
        '10.4': {
          $server_package_names  = ['mariadb-server']
          $cluster_package_names = $server_package_names
          $client_package_names  = ['mariadb-client']
          $galera_name           = 'galera-4'
          $backup_package_name   = 'mariadb-backup'
        }
        '10.5': {
          $server_package_names  = ['mariadb-server']
          $cluster_package_names = $server_package_names
          $client_package_names  = ['mysql-common', 'mariadb-client']
          $galera_name           = 'galera-4'
          $backup_package_name   = 'mariadb-backup'
        }
        default: {
          $server_package_names  = ['mariadb-server']
          $cluster_package_names = $server_package_names
          $client_package_names  = ['mariadb-client']
          $galera_name           = 'galera-3'
          $backup_package_name   = 'mariadb-backup'
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat, Debian")
    }
  }

  if $manage_repo == true {
    # Set up repositories
    class { $::mariadb::params::repo_class: }
    Class[$mariadb::params::repo_class]->Class['mariadb::package']
  }

  # Packages
  class { 'mariadb::package':
    package_names  => $client_package_names,
    package_ensure => $package_ensure,
  }

}
