# Class: mariadb
#
#   This class installs mariadb client software.
#
# Parameters:
#   [*package_ensure*]
#     Ensure value for the package. Set to `present` or a version number.
#     If setting a version number see note below on `repo_version`. Ex.
#     '5.5.37'.
#   [*package_names*]
#     Array of names of the mariadb client packages.
#   [*repo_version*]
#     Sets the version string for the repo URL. For Debian-based systems a
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
  $package_names  = $mariadb::params::client_package_names,
  $repo_version   = '5.5',
  $manage_repo    = true,
  $mirror         = 'http://mirror.aarnet.edu.au/pub/MariaDB',) inherits mariadb::params {
  if $manage_repo == true {
    # Set up repositories
    class { $mariadb::params::repo_class: stage => setup, }
  }

  # Packages
  class { 'mariadb::package':
    package_names  => $package_names,
    package_ensure => $package_ensure,
  }

}
git@github.com:zoide/puppet-mariadb.git