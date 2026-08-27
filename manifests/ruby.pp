# Class: mariadb::ruby
#
# installs the ruby bindings for mariadb
#
# Parameters:
#   [*ensure*]       - ensure state for package.
#                        can be specified as version.
#   [*package_name*] - name of package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::ruby (
  String[1]           $package_name     = $mariadb::params::ruby_package_name,
  Optional[String[1]] $package_provider = $mariadb::params::ruby_package_provider,
  String[1]           $package_ensure   = 'present'
) inherits mariadb::params {

  package{ 'ruby_mysql':
    ensure   => $package_ensure,
    name     => $package_name,
    provider => $package_provider,
  }

}
