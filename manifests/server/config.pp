# Creates a my.cnf like config file in the conf.d/ directory.
#
# IMPORTANT: this should be used AFTER the inclusion of
#            mariadb::server because it needs some variables
#            out of the mariadb::config class which will be
#            included!
#
# == Parameters:
#
# - name: is the name of the file
# - notify_service: whether to notify the mariadb daemon or not (default: true)
# - settings: either a string which should be the content of the file
#     or a hash with the following structure
#
#     section => {
#       <key> => <value>,
#       ...
#     },
#     ...
#
#   +section+ means all these sections you can set in
#             an configuration file like +mysqld+, +client+,
#             +mysqldump+ and so on
#   +key+ has to be a valid property which you can set like
#         +datadir+, +socket+ or even flags like +read-only+
#
#   +value+ can be
#     a) a string as the value
#     b) +true+ or +false+ to set a flag like 'read-only' or leave
#        it out (+false+ means, nothing will be done)
#     c) an array of values which can be of type a) and/or b)
#
#
# == Examples:
#
#   Easy one:
#
#   mariadb::server::config { 'basic_config':
#     settings => "[mysqld]\nskip-external-locking\n"
#   }
#
#   This will create the file /etc/mysql/conf.d/basic_config.cnf with
#   the following content:
#
#   [mariadbd]
#   skip-external-locking
#
#
#   More complex example:
#
#   mariadb::server::config { 'basic_config':
#     settings => {
#       'mysqld' => {
#         'query_cache_limit'     => '5M',
#         'query_cache_size'      => '128M',
#         'port'                  => 3300,
#         'skip-external-locking' => true,
#         'replicate-ignore-db'   => [
#           'tmp_table',
#           'whateveryouwant'
#         ]
#       },
#
#       'client' => {
#         'port' => 3300
#       }
#     }
#   }
#
#   This will create the file /etc/mysql/conf.d/basic_config.cnf with
#   the following content:
#
#   [mysqld]
#   query_cache_limit = 5M
#   query_cache_size = 128M
#   port = 3300
#   skip-external-locking
#   replicate-ignore-db = tmp_table
#   replicate-ignore-db = whateveryouwant
#
#   [client]
#   port = 3300
#
define mariadb::server::config (
  Hash $settings,
  Boolean $notify_service = true,
  String $config_dir      = $mariadb::params::config_dir,
) {
  include mariadb::params
  include mariadb::config

  file { "${config_dir}/${name}.cnf":
    ensure  => file,
    content => template('mariadb/my.conf.cnf.erb'),
    owner   => 'root',
    group   => $mariadb::config::root_group,
    mode    => '0644',
    require => Class['mariadb::server'],
  }

  if $notify_service {
    File["${config_dir}/${name}.cnf"] {
      # XXX notifying the Service gives us a dependency circle but I don't understand why
      notify => Exec['mariadb-restart']
    }
  }
}
