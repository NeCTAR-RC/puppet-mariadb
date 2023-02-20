# Class: mariadb::params
#
#   The mariadb configuration settings.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mariadb::params {

  $bind_address          = '127.0.0.1'
  $port                  = 3306
  $etc_root_password     = false
  $ssl                   = false
  $restart               = true
  $slave_threads         = $::processorcount * 2
  $version               = '5.5'
  $server_package_ensure = 'installed'
  $service_provider      = undef

  case $::osfamily {
    'RedHat': {
      $basedir                = '/usr'
      $datadir                = '/var/lib/mysql'
      $tmpdir                 = '/tmp'
      $service_name           = 'mysql'
      $client_package_names   = ['MariaDB-client']
      $client_package_ensure  = 'installed'
      $server_package_names   = ['MariaDB-server']
      $cluster_package_names  = ['MariaDB-Galera-server']
      $cluster_package_ensure = 'installed'
      $galera_package_name    = 'galera'
      $socket                 = '/var/lib/mysql/mysql.sock'
      $pidfile                = '/var/run/mysqld/mysqld.pid'
      $config_file            = '/etc/my.cnf'
      $config_file_symlink    = false
      $config_dir             = '/etc/my.cnf.d'
      $log_error              = '/var/log/mysqld.log'
      $ruby_package_name      = 'ruby-mysql'
      $ruby_package_provider  = 'gem'
      $python_package_name    = 'MySQL-python'
      $php_package_name       = 'php-mysql'
      $java_package_name      = 'mysql-connector-java'
      $root_group             = 'root'
      $ssl_ca                 = "${config_dir}/cacert.pem"
      $ssl_cert               = "${config_dir}/server-cert.pem"
      $ssl_key                = "${config_dir}/server-key.pem"
      $repo_class             = 'mariadb::repo::redhat'
      $wsrep_provider         = '/usr/lib64/galera/libgalera_smm.so'
      $default_mirror         = '"http://yum.mariadb.org'
      $backup_package_name    = 'MariaDB-backup'
    }

    'Debian': {
      $basedir                = '/usr'
      $datadir                = '/var/lib/mysql'
      $tmpdir                 = '/tmp'
      $service_name           = 'mysql'
      $client_package_names   = ['libmysqlclient18', 'mysql-common', 'mariadb-client']
      $client_package_ensure  = 'installed'
      $server_package_names   = ['mariadb-server']
      $cluster_package_names  = ['mariadb-galera-server']
      $cluster_package_ensure = 'installed'
      $galera_package_name    = 'galera'
      $socket                 = '/var/run/mysqld/mysqld.sock'
      $pidfile                = '/var/run/mysqld/mysqld.pid'
      $config_file            = '/etc/mysql/mariadb.cnf'
      $config_file_symlink    = true
      $config_dir             = '/etc/mysql/conf.d'
      $log_error              = '/var/log/mysql/error.log'
      $ruby_package_name      = 'libmysql-ruby'
      $python_package_name    = 'python-mysqldb'
      $php_package_name       = 'php5-mysql'
      $java_package_name      = 'libmysql-java'
      $root_group             = 'root'
      $ssl_ca                 = "${config_dir}/cacert.pem"
      $ssl_cert               = "${config_dir}/server-cert.pem"
      $ssl_key                = "${config_dir}//server-key.pem"
      $repo_class             = 'mariadb::repo::debian'
      $wsrep_provider         = '/usr/lib/galera/libgalera_smm.so'
      $default_mirror         = 'http://mirror.aarnet.edu.au/pub/MariaDB'
      $backup_package_name    = 'mariadb-backup-10.1'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat, Debian")
    }
  }

}
