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
#   [*debiansysmaint_password*]
#     Password for the debian-sys-maint user. Accepts a Sensitive value.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::server (
  String[1]                  $package_ensure   = $mariadb::params::server_package_ensure,
  Optional[Array[String[1]]] $package_names    = undef,
  String[1]                  $service_name     = $mariadb::params::service_name,
  Optional[String[1]]        $service_provider = $mariadb::params::service_provider,
  Optional[Variant[String[1], Sensitive[String[1]]]] $debiansysmaint_password = undef,
  Hash                       $config_hash      = {},
  Boolean                    $enabled          = true,
  Boolean                    $manage_service   = true,
) inherits mariadb::params {
  include mariadb

  if $package_names == undef {
    $real_package_names = $mariadb::server_package_names
  } else {
    $real_package_names = $package_names
  }

  Class['mariadb::server'] -> Class['mariadb::config']

  $config_class = { 'mariadb::config' => $config_hash }

  create_resources( 'class', $config_class )

  package { $real_package_names:
    ensure => $package_ensure,
  }

  # MariaDB 11.4+ packages no longer ship the mysql-named command symlinks,
  # but the puppetlabs-mysql providers (mysql_grant, mysql_user etc.) are
  # only considered suitable when the mysql, mysqld and mysqladmin commands
  # all exist. Restore the symlinks so those providers keep working.
  if versioncmp($mariadb::version, '11.4') >= 0 {
    file {
      default:
        ensure  => link,
        require => Package[$real_package_names],
      ;
      '/usr/bin/mysql':
        target => '/usr/bin/mariadb',
      ;
      '/usr/bin/mysqladmin':
        target => '/usr/bin/mariadb-admin',
      ;
      '/usr/sbin/mysqld':
        target => '/usr/sbin/mariadbd',
      ;
    }
  }

  file { '/var/log/mysql/error.log':
    owner   => mysql,
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
  if $debiansysmaint_password {
    class { 'mariadb::server::debiansysmaint':
      password => $debiansysmaint_password,
    }
  }
}
