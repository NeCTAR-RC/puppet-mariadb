class mariadb($local_backup=false) {

  $mysql_root_password = hiera('mysql_root_password')

  include mariadb::packages

  # Require these package versions, or mariadb won't install. Ubuntu has packaged
  # newer versions, which break the dependencies.
  package { ['libmysqlclient18', 'mysql-common']:
    ensure => '5.5.30-mariadb1~precise',
    require => Apt::Source['mariadb'],
    before  => Package['mariadb-galera-server']
  }

  package { ['mariadb-galera-server', 'galera']:
    ensure => installed
  }

  service { 'mysql':
    ensure  => running,
    require => Package['mariadb-galera-server'],
  }

  exec { 'set-mysql-root-password':
    unless => "mysqladmin -uroot -p${mysql_root_password} status",
    path => ['/bin', '/usr/bin'],
    command => "mysqladmin -uroot password ${mysql_root_password}",
    require => Service['mysql'],
  }

  file { '/etc/mysql/my.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("mysql/my.cnf-${lsbdistcodename}.erb"),
    notify  => Service['mysql'],
    require => Package['mariadb-galera-server'],
  }

  if $local_backup {
    $backup_ensure = present
  } else {
    $backup_ensure = absent
  }
  
  file { '/usr/local/sbin/backup-mysql.sh':
    ensure  => $backup_ensure,
    owner   => root,
    group   => root,
    mode    => 0750,
    source  => 'puppet:///modules/mysql/backup-mysql.sh'
  }

  cron { backup-mysql:
    ensure  => $backup_ensure,
    command => '/usr/local/sbin/backup-mysql.sh',
    user    => root,
    hour    => '4',
    minute  => '0',
    require => File['/usr/local/sbin/backup-mysql.sh'],
  }

  nagios::nrpe::service {
    'check_mysqld':
      check_command  => '/usr/lib/nagios/plugins/check_mysql',
      servicegroups => 'databases',
    }

  define db( $user, $password, $access='localhost' ) {
    exec { "create-${name}-db":
      command => "mysql -u root -p${mysql_root_password} -e \"CREATE DATABASE ${name};\"",
      creates => "/var/lib/mysql/${name}/",
      path    => "/bin:/usr/bin",
      require => Service["mysql"],
    }

    mariadb::user { $user:
      user     => $user,
      password => $password,
      database => $name,
      grant    => 'read-write',
      access   => $access,
    }
  }
}
