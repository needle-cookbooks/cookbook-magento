require 'rubygems'
if Gem.available?('mysql')
  Gem.clear_paths
  require 'mysql'
end

execute "mysql-install-mage-privileges" do
  command "/usr/bin/mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} -h#{node[:magento][:db][:host]} < /etc/mysql/mage-grants.sql"
  action :nothing
end

template "/etc/mysql/mage-grants.sql" do
  path "/etc/mysql/mage-grants.sql"
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(:database => node[:magento][:db])
  notifies :run, resources(:execute => "mysql-install-mage-privileges"), :immediately
end


execute "create #{node[:magento][:db][:database]} database" do
  command "/usr/bin/mysqladmin -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} -h#{node[:magento][:db][:host]} create #{node[:magento][:db][:database]}"
  not_if do
    m = Mysql.new(node[:magento][:db][:host], node[:magento][:db][:username], node[:magento][:db][:password])
    m.list_dbs.include?(node[:magento][:db][:database])
  end
end

# save node data after writing the MYSQL root password, so that a failed chef-client run that gets this far doesn't cause an unknown password to get applied to the box without being saved in the node data.
ruby_block "save node data" do
  block do
    node.save
  end
  action :create
end
