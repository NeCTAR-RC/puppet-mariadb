# Class: mariadb::packages
#
#   This class installs mariadb client software.
#
class mariadb::packages($package_names, $package_ensure) {

  package { $package_names:
    ensure => $package_ensure,
  }
}
