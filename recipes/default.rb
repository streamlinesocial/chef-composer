#
# Cookbook Name:: composer
# Recipe:: default
#
# Copyright 2012, Escape Studios
#

include_recipe "php"

#install/upgrade curl
package "curl" do
    action :upgrade
end

# base install command
install_command = "curl -s https://getcomposer.org/installer | php"

# only if installing locally do we add the flag directing where to install it
unless node['composer']['install_globally']
    unless node['composer']['install_dir'].nil? || node['composer']['install_dir'].empty?
        install_command = install_command + " -- --install-dir=#{node['composer']['install_dir']}"
    end
end

# if not yet installed, download the phar
# if installing locally, we're done, the above code will define the final install-dir
bash 'dowload_composer' do
    creates "#{node['composer']['prefix']}/bin/composer"
    cwd Chef::Config['file_cache_path']
    command install_command
end

# when installing globally, we move it to a global spot after install
if node['composer']['install_globally']
    execute 'move_composer' do
        creates "#{node['composer']['prefix']}/bin/composer"
        cwd Chef::Config["file_cache_path"]
        command "mv composer.phar #{node['composer']['prefix']}/bin/composer"
    end
end
