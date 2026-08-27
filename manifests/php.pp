# Class: mariadb::php
#
# This class installs the php libs for mariadb.
#
# Parameters:
#   [*package_name*]   - name of package
#   [*package_ensure*] - ensure state for package.
#                        can be specified as version.
#
class mariadb::php (
  String[1] $package_name   = $mariadb::params::php_package_name,
  String[1] $package_ensure = 'present'
) inherits mariadb::params {
  package { 'php-mysql':
    ensure => $package_ensure,
    name   => $package_name,
  }
}
