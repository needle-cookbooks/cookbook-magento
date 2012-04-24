include_recipe %w{magento apache2 apache2::mod_deflate apache2::mod_expires apache2::mod_headers apache2::mod_rewrite apache2::mod_ssl}

if node.has_key?("ec2")
  server_fqdn = node.ec2.public_hostname
else
  server_fqdn = node.fqdn
end

%w{magento magento_ssl}.each do |site|
  web_app "#{site}" do
    template "apache-site.conf.erb"
    docroot "#{node[:magento][:dir]}"
    server_name server_fqdn
    server_aliases node.fqdn
    ssl (site == "magento_ssl")?true:false
  end
end

%w{default 000-default}.each do |site|
  apache_site "#{site}" do
    enable false
  end
end

execute "ensure correct permissions" do
  command "chown -R root:#{node[:apache][:user]} #{node[:magento][:dir]} && chmod -R g+rw #{node[:magento][:dir]}"
  action :run
end
