# Class: mariadb::package
#
#   This class installs mariadb client software.
#
# Parameters:
#   [*package_names*]  - Array of names of packages to install.
#   [*package_ensure*] - Ensure value for the packages.
#
class mariadb::package (
  Array[String[1]] $package_names,
  String[1]        $package_ensure,
) {
  package { $package_names:
    ensure => $package_ensure,
  }
}
