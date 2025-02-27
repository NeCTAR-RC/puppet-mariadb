# Define: mariadb::db
#
# This module creates database instances, a user, and grants that user
# privileges to the database.  It can also import SQL from a file in order to,
# for example, initialize a database schema.
#
# Since it requires class mariadb::server, we assume to run all commands as the
# root mariadb user against the local mariadb server.
#
# Parameters:
#   [*title*]       - mariadb database name.
#   [*user*]        - username to create and grant access.
#   [*password*]    - user's password.
#   [*charset*]     - database charset.
#   [*host*]        - host for assigning privileges to user.
#   [*grant*]       - array of privileges to grant user.
#   [*enforce_sql*] - whether to enforce or conditionally run sql on creation.
#   [*sql*]         - sql statement to run.
#   [*ensure*]      - specifies if a database is present or absent.
#
# Actions:
#
# Requires:
#
#   class mariadb::server
#
# Sample Usage:
#
#  mariadb::db { 'mydb':
#    user     => 'my_user',
#    password => 'password',
#    host     => $::hostname,
#    grant    => ['all']
#  }
#
define mariadb::db (
  String                    $user,
  String                    $password,
  String                    $charset     = 'utf8',
  String                    $host        = 'localhost',
  String                    $grant       = 'all',
  Optional[String]          $sql         = undef,
  Boolean                   $enforce_sql = false,
  Enum['present', 'absent'] $ensure      = 'present'
) {

  if $mariadb::version == '10.6' and $charset == 'utf8' {
    $_charset = 'utf8mb3'
  } elsif $mariadb::version == '10.11' and $charset == 'utf8' {
    $_charset = 'utf8mb4'
  } elsif $mariadb::version == '11.4' and $charset == 'utf8' {
    $_charset = 'utf8mb4'
  } else {
    $_charset = $charset
  }

  database { $name:
    ensure  => $ensure,
    charset => $_charset,
    require => Class['mariadb::server'],
  }

  database_user { "${user}@${host}":
    ensure        => $ensure,
    password_hash => mysql_password($password),
    require       => Database[$name],
  }

  if $ensure == 'present' {
    mysql_grant { "${user}@${host}/${name}.*":
      user       => "${user}@${host}",
      table      => "${name}.*",
      privileges => $grant,
      require    => Database_user["${user}@${host}"],
    }

    $refresh = ! $enforce_sql

    if $sql {
      exec{ "${name}-import":
        command     => "/usr/bin/mysql ${name} < ${sql}",
        logoutput   => true,
        refreshonly => $refresh,
        require     => Database_grant["${user}@${host}/${name}"],
        subscribe   => Database[$name],
      }
    }
  }
}
