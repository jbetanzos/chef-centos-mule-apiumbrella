#
# Cookbook Name:: lyrisdemo
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe "java"
include_recipe "maven"
package 'mysql'
package 'epel-release'

yum_package 'docker-io' do
  options '--enablerepo=epel'
end

service 'docker' do
  action [:enable, :start]
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

execute "configure_apiumbrella" do
  command 'yum install -y /vagrant/resources/api-umbrella-0.8.0-1.el6.x86_64.rpm'
  not_if '[ -f /etc/init.d/api-umbrella ]'
  action :run
end

bash "configure_mule" do
  user "root"
  cwd "/opt"
  code <<-EOH
    tar -zxf /vagrant/resources/mule-standalone-3.5.0.tar.gz
    (ln -s /opt/mule-standalone-3.5.0 /opt/mule)
  EOH
  environment 'MULE_HOME' => '/opt/mule'
  action :nothing
  notifies :run, "execute[start-mule]", :immediately
end

execute 'start-mule' do
  command '/opt/mule/bin/mule -M-Dmule.mmc.bind.port=7773 -Wwrapper.daemonize=TRUE'
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
  port      8083
  action    :allow
end