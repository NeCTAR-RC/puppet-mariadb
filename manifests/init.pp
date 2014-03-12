# Class: mariadb
#
#   This class installs mariadb client software.
#
# Parameters:
#   [*client_package_names*] - Array of names of the mariadb client packages.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb (
  $package_names  = $mariadb::params::client_package_names,
  $package_ensure = 'present'
) inherits mariadb::params {

  anchor {'mariadb::begin': }
  anchor {'mariadb::end': }

  # Set up repositories
  class { 'mariadb::repos': }

  # Packages
  class { 'mariadb::packages':
    package_names  => $package_names,
    package_ensure => $package_ensure,
  }

  # Ensure that we set up the repositories before trying to install
  # the packages
  Anchor['mariadb::begin']
  -> Class['mariadb::repos']
  -> Class['mariadb::packages']
  -> Anchor['mariadb::end']

}
