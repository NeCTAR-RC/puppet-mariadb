# Class: mariadb::config
#
# Parameters:
#
#   [*root_password*]     - root user password. Accepts a Sensitive value.
#   [*old_root_password*] - previous root user password. Accepts a Sensitive
#                           value.
#   [*bind_address*]      - address to bind service.
#   [*port*]              - port to bind service.
#   [*etc_root_password*] - whether to save /etc/my.cnf.
#   [*service_name*]      - mariadb service name.
#   [*config_dir*]        - path to the conf.d configuration directory.
#   [*config_file*]       - my.cnf configuration file path.
#   [*config_file_symlink*] - whether to symlink /etc/mysql/my.cnf to
#                           config_file.
#   [*socket*]            - mariadb socket.
#   [*pidfile*]           - path to the pid file.
#   [*datadir*]           - path to datadir.
#   [*tmpdir*]            - path to tmpdir.
#   [*ssl*]               - enable ssl
#   [*ssl_ca*]            - path to ssl-ca
#   [*ssl_cert*]          - path to ssl-cert
#   [*ssl_key*]           - path to ssl-key
#   [*log_error*]         - path to mariadb error log
#   [*default_engine*]    - configure a default table engine
#   [*root_group*]        - use specified group for root-owned files
#   [*restart*]           - whether to restart mariadbd (true/false)
#   [*purge_conf_dir*]    - whether to purge unmanaged files from the conf.d
#                           configuration directory
#
# Actions:
#
# Requires:
#
#   class mariadb::server
#
# Usage:
#
#   class { 'mariadb::config':
#     root_password => 'changeme',
#     bind_address  => $::ipaddress,
#   }
#
class mariadb::config (
  Variant[String, Sensitive[String]] $root_password               = 'UNSET',
  Optional[Variant[String, Sensitive[String]]] $old_root_password = undef,
  String[1]                     $bind_address        = $mariadb::params::bind_address,
  Stdlib::Port                  $port                = $mariadb::params::port,
  Boolean                       $etc_root_password   = $mariadb::params::etc_root_password,
  String[1]                     $service_name        = $mariadb::params::service_name,
  Stdlib::Absolutepath          $config_dir          = $mariadb::params::config_dir,
  Stdlib::Absolutepath          $config_file         = $mariadb::params::config_file,
  Boolean                       $config_file_symlink = $mariadb::params::config_file_symlink,
  Stdlib::Absolutepath          $socket              = $mariadb::params::socket,
  Stdlib::Absolutepath          $pidfile             = $mariadb::params::pidfile,
  Stdlib::Absolutepath          $datadir             = $mariadb::params::datadir,
  Stdlib::Absolutepath          $tmpdir              = $mariadb::params::tmpdir,
  Boolean                       $ssl                 = $mariadb::params::ssl,
  Optional[Stdlib::Absolutepath] $ssl_ca             = $mariadb::params::ssl_ca,
  Optional[Stdlib::Absolutepath] $ssl_cert           = $mariadb::params::ssl_cert,
  Optional[Stdlib::Absolutepath] $ssl_key            = $mariadb::params::ssl_key,
  Stdlib::Absolutepath          $log_error           = $mariadb::params::log_error,
  String[1]                     $default_engine      = 'UNSET',
  String[1]                     $root_group          = $mariadb::params::root_group,
  Boolean                       $restart             = $mariadb::params::restart,
  Boolean                       $purge_conf_dir      = false
) inherits mariadb::params {
  $real_root_password = $root_password.unwrap
  $real_old_root_password = $old_root_password.unwrap

  $restart_notify = $restart ? {
    true  => Exec['mariadb-restart'],
    false => undef,
  }

  File {
    owner  => 'root',
    group  => $root_group,
    mode   => '0400',
    notify => $restart_notify,
  }

  if $ssl and $ssl_ca == undef {
    fail('The ssl_ca parameter is required when ssl is true')
  }

  if $ssl and $ssl_cert == undef {
    fail('The ssl_cert parameter is required when ssl is true')
  }

  if $ssl and $ssl_key == undef {
    fail('The ssl_key parameter is required when ssl is true')
  }

  # Using rsync with a MariaDB Galera cluster means that sometimes the DB
  # won't start up properly because rsync is still running. We kill it here
  # before starting the service to give us a better chance.
  exec { 'mariadb-restart':
    command     => "service ${service_name} restart",
    logoutput   => on_failure,
    path        => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
    refreshonly => true,
  }

  # manage root password if it is set
  if $real_root_password != 'UNSET' {
    case $real_old_root_password {
      undef, '': { $old_pw='' }
      default:   { $old_pw="-p'${real_old_root_password}'" }
    }

    exec { 'set_mariadb_rootpw':
      command   => Sensitive("mariadb-admin -u root ${old_pw} password '${real_root_password}'"),
      logoutput => true,
      unless    => Sensitive("mariadb-admin -u root -p'${real_root_password}' status > /dev/null"),
      path      => '/usr/local/sbin:/usr/bin:/usr/local/bin',
      notify    => $restart_notify,
      require   => File[$mariadb::params::config_dir],
    }

    file { '/root/.my.cnf':
      content => Sensitive(template('mariadb/my.cnf.pass.erb')),
      require => Exec['set_mariadb_rootpw'],
    }

    if $etc_root_password {
      file { '/etc/my.cnf':
        content => Sensitive(template('mariadb/my.cnf.pass.erb')),
        require => Exec['set_mariadb_rootpw'],
      }
    }
  } else {
    file { '/root/.my.cnf':
      ensure => file,
    }
  }

  $config_file_dir = dirname($config_file)

  file { $config_file_dir:
    ensure => directory,
    mode   => '0755',
  }
  file { $config_dir:
    ensure  => directory,
    mode    => '0755',
    recurse => $purge_conf_dir,
    purge   => $purge_conf_dir,
  }
  file { $config_file:
    content => template("mariadb/my.cnf-${mariadb::version}.erb"),
    mode    => '0644',
  }

  if $config_file_symlink {
    file { '/etc/mysql/my.cnf':
      ensure => link,
      target => $config_file,
    }
  }

  $debiansysmaint_password = $mariadb::server::debiansysmaint_password
  if $debiansysmaint_password != undef {
    $real_debiansysmaint_password = $debiansysmaint_password.unwrap

    file { '/etc/mysql/debian.cnf':
      content => Sensitive(template('mariadb/debian.cnf.erb')),
    }
  }
}
