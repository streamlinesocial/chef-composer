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
install_destination = "#{node['composer']['prefix']}/bin/composer"

# only if installing locally do we add the flag directing where to install it
unless node['composer']['install_globally']
    unless node['composer']['install_dir'].nil? || node['composer']['install_dir'].empty?
        install_destination "#{node['composer']['install_dir']}/composer.phar"
        install_command = install_command + " -- --install-dir=#{node['composer']['install_dir']}"
    end
end

# if not yet installed, download the phar
# if installing locally, we're done, the above code will define the final install-dir
execute install_command do
    not_if "test -f #{install_destination}"
    cwd Chef::Config['file_cache_path']
    command install_command
    if node['composer']['install_globally']
        notifies :run, "execute[move_composer]", :immediately
    end
end

# when installing globally, we move it to a global spot after install
execute 'move_composer' do
    action :nothing
    cwd Chef::Config["file_cache_path"]
    command "mv composer.phar #{install_destination}"
end

# if we are given an oauth token, we will use this to setup composer
# there are few concerns here, but we want to be able to deploy without
# rate limiting. recommend using a user that is not your day to day user
# https://github.com/everzet/capifony/issues/358
# if node['composer']['github_oauth_token']
#     execute "#{install_destination} config --global github-oauth.github.com #{node['composer']['github_oauth_token']}" do
#         action :run
#     end
# end
