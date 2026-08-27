# Class: mariadb::server::debiansysmaint
#
# Manages the debian-sys-maint database user.
#
# Parameters:
#   [*password*] - Password for the debian-sys-maint user. Accepts a
#                  Sensitive value.
#
class mariadb::server::debiansysmaint (
  Variant[String[1], Sensitive[String[1]]] $password,
) {
  $real_password = $password.unwrap

  database_user { 'debian-sys-maint@localhost':
    ensure        => present,
    password_hash => Sensitive(mysql_password($real_password)),
    require       => Class['mariadb::server'],
  }

  mysql_grant { 'debian-sys-maint@localhost/*.*':
    user       => 'debian-sys-maint@localhost',
    table      => '*.*',
    privileges => ['all'],
    require    => Database_user['debian-sys-maint@localhost'],
  }
}
