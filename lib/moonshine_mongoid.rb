require 'pathname'

module MoonshineMongoid
  def self.included(base)
    manifest.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def mongodb_template_dir
      @mongodb_template_dir ||= Pathname.new(__FILE__).dirname.dirname.join('templates')
    end
  end

  def mongodb(hash={})
    # TODO: Add configuration options for /etc/mongodb.conf
    exec 'add_mongodb_repos',
      :command => ["apt-add-repository 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen'",
                   "apt-add-repository --remove 'deb-src http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen'",
                   "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"].join(' && '),
      :unless => "grep 10gen /etc/apt/sources.list",
      :require => '/etc/apt/sources.list'

    package 'mongodb-10gen', :ensure => :installed

    service "mongodb",
      :ensure => :running,
      :enable => true

    if respond_to?(:god)
      recipe :god
      file "/etc/god/#{configuration[:application]}-mongodb.god",
        :ensure => :present,
        :require => file('/etc/god/god.conf'),
        :content => template(mongoid_template_dir.join('mongodb.god')),
        :notify => exec('restart_god')
    end
  end
end
