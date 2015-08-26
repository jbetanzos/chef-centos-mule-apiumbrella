#
# Cookbook Name:: lyrisdemo
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe "java"
include_recipe "maven"

# Configure the mysql2 Ruby gem.
mysql2_chef_gem 'default' do
  action :install
end

# Configure the MySQL client.
mysql_client 'default' do
  action :create
end

# Configure the MySQL service.
mysql_service 'default' do
  initial_root_password 'betanzos'
  notifies :run, "execute[sock-link]", :immediately
  action [:create, :start]
end

# Add a database user.
mysql_database_user 'demouser' do
  connection(
    :host => '127.0.0.1',
    :username => 'root',
    :password => 'betanzos'
  )
  password 'demouser'
  host '127.0.0.1'
  action [:create, :grant]
end

remote_file "/vagrant/resources/mule-standalone-3.5.0.tar.gz" do
  source "https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/3.5.0/mule-standalone-3.5.0.tar.gz"
  not_if '[ -f /vagrant/resources/mule-standalone-3.5.0.tar.gz ]'
  notifies :run, "bash[configure_mule]", :immediately
end

remote_file "/vagrant/resources/api-umbrella-0.8.0-1.el6.x86_64.rpm" do
  source "https://developer.nrel.gov/downloads/api-umbrella/el/6/api-umbrella-0.8.0-1.el6.x86_64.rpm"
  not_if '[ -f /vagrant/resources/api-umbrella-0.8.0-1.el6.x86_64.rpm ]'
  notifies :run, "execute[configure_apiumbrella]", :immediately
end

bash "configure_mule" do
  user "root"
  cwd "/opt"
  code <<-EOH
    tar -zxf /vagrant/resources/mule-standalone-3.5.0.tar.gz
    ln -s /opt/mule-standalone-3.5.0 /opt/mule
    rm -rf /opt/mule-standalone-3.5.0/apps
    ln -fs /vagrant/mule/apps /opt/mule-standalone-3.5.0/apps
  EOH
  environment 'MULE_HOME' => '/opt/mule'
  only_if '[ -f /vagrant/resources/mule-standalone-3.5.0.tar.gz ]'
  not_if '[ -f /opt/mule/bin/mule ]'
  action :run
  notifies :run, "execute[start-mule]", :immediately
end

execute "configure_apiumbrella" do
  command 'yum install -y /vagrant/resources/api-umbrella-0.8.0-1.el6.x86_64.rpm'
  not_if '[ -f /etc/init.d/api-umbrella ]'
  action :run
end

execute "sock-link" do
  command 'ln -fs /var/run/mysql-default/mysqld.sock /var/lib/mysql/mysql.sock'
  not_if '[ -h /var/lib/mysql/mysql.sock ]'
  action :nothing
end

execute 'start-mule' do
  command '/opt/mule/bin/mule -M-Dmule.mmc.bind.port=7773 -Wwrapper.daemonize=TRUE'
  only_if '[ -f /opt/mule/bin/mule ]'
  not_if '[ $(/opt/mule/bin/mule status) != *"not running"* ]'
  action :run
end

firewall 'ufw' do
  action :enable
end

firewall_rule 'apiumbrella' do
  port      [80, 443]
  action    :allow
end

firewall_rule 'mule-appsftw35' do
  port      8081
  action    :allow
end