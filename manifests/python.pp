# Class: mariadb::python
#
# This class installs the python libs for mariadb.
#
# Parameters:
#   [*package_name*]   - name of package
#   [*package_ensure*] - ensure state for package.
#                        can be specified as version.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::python (
  String[1] $package_name   = $mariadb::params::python_package_name,
  String[1] $package_ensure = 'present'
) inherits mariadb::params {
  package { 'python-mysqldb':
    ensure => $package_ensure,
    name   => $package_name,
  }
}
