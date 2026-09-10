Puppet::Type.type(:database).provide(:mysql) do
  desc "Manages MySQL database."

  defaultfor :kernel => 'Linux'

  # MariaDB 11.4+ no longer ships the mysql/mysqladmin command names, so use
  # the mariadb-named binaries (available since MariaDB 10.4.6).
  optional_commands :mariadb       => 'mariadb'
  optional_commands :mariadb_admin => 'mariadb-admin'

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

  def self.instances
    mariadb([defaults_file, '-NBe', "show databases"].compact).split("\n").collect do |name|
      new(:name => name)
    end
  end

  def create
    mariadb([defaults_file, '-NBe', "create database `#{@resource[:name]}` character set #{resource[:charset]}"].compact)
  end

  def destroy
    mariadb_admin([defaults_file, '-f', 'drop', @resource[:name]].compact)
  end

  def charset
    mariadb([defaults_file, '-NBe', "show create database `#{resource[:name]}`"].compact).match(/.*?(\S+)\s(?:COLLATE.*)?\*\//)[1]
  end

  def charset=(value)
    mariadb([defaults_file, '-NBe', "alter database `#{resource[:name]}` CHARACTER SET #{value}"].compact)
  end

  def exists?
    begin
      mariadb([defaults_file, '-NBe', "show databases"].compact).match(/^#{@resource[:name]}$/)
    rescue => e
      debug(e.message)
      return nil
    end
  end

end
