class mariadb::server::debiansysmaint (
  $password,
) {

  database_user { 'debian-sys-maint@localhost':
    ensure        => present,
    password_hash => mysql_password($password),
    require       => Class['mariadb::server'],
  }

  mysql_grant { 'debian-sys-maint@localhost/*.*':
    user       => 'debian-sys-maint@localhost',
    table      => '*.*',
    privileges => [ 'ALTER', 'ALTER ROUTINE', 'BINLOG ADMIN', 'BINLOG MONITOR', 'BINLOG REPLAY', 'CONNECTION ADMIN',
                    'CREATE', 'CREATE ROUTINE', 'CREATE TEMPORARY TABLES', 'CREATE USER', 'CREATE VIEW', 'DELETE',
                    'DROP', 'EVENT', 'EXECUTE', 'FEDERATED ADMIN', 'FILE', 'INDEX', 'INSERT', 'LOCK TABLES', 'PROCESS',
                    'READ_ONLY ADMIN', 'REFERENCES', 'RELOAD', 'REPLICATION MASTER ADMIN', 'REPLICATION SLAVE',
                    'REPLICATION SLAVE ADMIN', 'SELECT', 'SET USER', 'SHOW DATABASES', 'SHOW VIEW', 'SHUTDOWN',
                    'SLAVE MONITOR', 'SUPER', 'TRIGGER', 'UPDATE'],
    require    => Database_user['debian-sys-maint@localhost'],
  }

}
