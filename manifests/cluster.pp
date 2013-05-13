class mariadb::cluster inherits mariadb {

  $server_ips = hiera('mysql_servers')

  $cluster_peer = inline_template("<% (0..server_ips.length).each do |i|; if server_ips[i] == ipaddress; if (i+1) == server_ips.length %><%= server_ips[0] %><% else %><%= server_ips[i+1] %><% end; end; end %>")

  file { '/etc/mysql/conf.d/mariadb.cnf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('mariadb/mariadb.cnf.erb'),
    notify  => Service['mysql'],
    require => Package['galera'],
  }

}
