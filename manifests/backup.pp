# Class: mariadb::backup
#
# This module handles ...
#
# Parameters:
#   [*backupuser*]     - The name of the mariadb backup user.
#   [*backuppassword*] - The password of the mariadb backup user.
#   [*backupdir*]      - The target directory of the mariadbdump.
#   [*backupcompress*] - Boolean to compress backup with bzip2.
#   [*backupdays*]     - Number of days of backups to keep.
#   [*onefile*]        - Dump all DBs into one file?
#   [*ensure*]         - Specify if database backup is present or absent.
#   [*backupmethod*]   - Backup methods to select: mysqldump or mariabackup
#
# Actions:
#   GRANT SELECT, RELOAD, LOCK TABLES ON *.* TO 'user'@'localhost'
#    IDENTIFIED BY 'password';
#
# Requires:
#   Class['mariadb::config']
#
# Sample Usage:
#   class { 'mariadb::backup':
#     backupuser     => 'myuser',
#     backuppassword => 'mypassword',
#     backupdir      => '/tmp/backups',
#     backupcompress => true,
#     backupdays     => 30,
#   }
#
class mariadb::backup (
  $backupuser,
  $backuppassword,
  $backupdir,
  $backupdays = 30,
  $backupcompress = true,
  $onefile = true,
  $ensure = 'present',
  $backupmethod = 'mysqldump',
) {

  include ::mariadb

  database_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql_password($backuppassword),
    require       => Class['mariadb::server'],
  }

  $version = hiera('mariadb::version')
  if $version >= '10.5' {
    $grant = [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'BINLOG MONITOR', 'PROCESS', 'SUPER' ]
  } else {
    $grant = [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'REPLICATION CLIENT', 'PROCESS', 'SUPER' ]
  }
  mysql_grant { "${backupuser}@localhost/*.*":
    user       => "${backupuser}@localhost",
    table      => '*.*',
    privileges => $grant,
    require    => Database_user["${backupuser}@localhost"],
  }

  if $backupmethod == 'mariabackup' {
    ensure_packages([$::mariadb::backup_package_name])
    $backupscript = 'mariabackup.sh'
  } else {
    $backupscript = 'mysqlbackup.sh'
  }

  cron { 'mysql-backup':
    ensure  => $ensure,
    command => "/usr/local/sbin/${backupscript}",
    user    => 'root',
    hour    => fqdn_rand(5),
    minute  => fqdn_rand(59),
    require => File[$backupscript],
  }

  file { $backupscript:
    ensure  => $ensure,
    path    => "/usr/local/sbin/${backupscript}",
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template("mariadb/${backupscript}.erb"),
  }

  exec { "Create ${backupdir}":
    creates => $backupdir,
    command => "mkdir -p ${backupdir}",
    path    => $::path
  } -> file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }
}
