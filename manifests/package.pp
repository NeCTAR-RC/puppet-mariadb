# Class: mariadb::packages
#
#   This class installs mariadb client software.
#
class mariadb::package (
  Array[String[1]] $package_names,
  String[1]        $package_ensure,
) {

  package { $package_names:
    ensure => $package_ensure,
  }
}
