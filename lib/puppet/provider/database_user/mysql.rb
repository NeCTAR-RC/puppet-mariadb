Puppet::Type.type(:database_user).provide(:mysql) do

  desc "manage users for a mysql database."

  defaultfor :kernel => 'Linux'

  # MariaDB 11.4+ no longer ships the mysql/mysqladmin command names, so use
  # the mariadb-named binaries (available since MariaDB 10.4.6).
  optional_commands :mariadb       => 'mariadb'
  optional_commands :mariadb_admin => 'mariadb-admin'

  def self.instances
    users = mariadb([defaults_file, "mysql", '-BNe', "select concat(User, '@',Host) as User from mysql.user"].compact).split("\n")
    users.select{ |user| user =~ /.+@/ }.collect do |name|
      new(:name => name)
    end
  end

  def create
    mariadb([defaults_file, "mysql", "-e", "create user '%s' identified by PASSWORD '%s'" % [ @resource[:name].sub("@", "'@'"), @resource.value(:password_hash) ]].compact)
  end

  def destroy
    mariadb([defaults_file, "mysql", "-e", "drop user '%s'" % @resource.value(:name).sub("@", "'@'") ].compact)
  end

  def password_hash
    mariadb([defaults_file, "mysql", "-NBe", "select password from mysql.user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)].compact).chomp
  end

  def password_hash=(string)
    mariadb([defaults_file, "mysql", "-e", "SET PASSWORD FOR '%s' = '%s'" % [ @resource[:name].sub("@", "'@'"), string ] ].compact)
  end

  def exists?
    not mariadb([defaults_file, "mysql", "-NBe", "select '1' from mysql.user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)].compact).empty?
  end

  def flush
    @property_hash.clear
    mariadb_admin([defaults_file, "flush-privileges"].compact)
  end

  # Optional defaults file
  def self.defaults_file
    if File.file?("#{Facter.value(:root_home)}/.my.cnf")
      "--defaults-file=#{Facter.value(:root_home)}/.my.cnf"
    else
      nil
    end
  end
  def defaults_file
    self.class.defaults_file
  end

end
