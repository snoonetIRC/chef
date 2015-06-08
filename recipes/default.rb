#
# Cookbook Name:: snoonet-deploy
# Recipe:: default
#
# Copyright (C) 2015 SnooNet
#

# We can only install packages and create users if we're root
if ENV['USER'] == 'root'
    # If we're root, setup the environment
    include_recipe "#{cookbook_name}::environment"

    # Define parameters
    inspircdstop = [:stop, 'service[snoonet-inspircd]', :immediately]
    inspircdrestart = [:restart, 'service[snoonet-inspircd]', :immediately]
else
    inspircdstop = [:run, 'execute[Stop InspIRCd]', :immediately]
    inspircdrestart = [:run, 'execute[Restart InspIRCd]', :immediately]
end

# Create the directories the repo and deploy will live in
node['snoonet']['dirs'].each_pair { |key,dir|
    directory dir do
        owner node['snoonet']['user']
        group node['snoonet']['group']
        action :create
        recursive true
    end
}

# Sync the repo with git
git node['snoonet']['dirs']['repo'] do
    user node['snoonet']['user']
    group node['snoonet']['group']
    repository node['snoonet']['inspircd']['repo']
    action :sync
    notifies :run, 'execute[Configure InspIRCd]', :immediately
    notifies :run, 'execute[Compile InspIRCd]', :immediately
    if(::File.exist?("#{node['snoonet']['dirs']['deploy']}/bin/inspircd"))
        # We update!
        # Shutdown existing InspIRCd
        # notifies :stop, 'service[snoonet-inspircd]', :immediately
        notifies *inspircdstop
        # Move existing install directory to backup dir
        notifies :run, 'execute[Backup InspIRCd]', :immediately
        # Create new install directory
        notifies :create, "directory[#{node['snoonet']['dirs']['deploy']}]", :immediately
    end
    notifies :run, 'execute[Install InspIRCd]', :immediately
end

# Remove the conf directory if it's still a directory
directory "#{node['snoonet']['dirs']['deploy']}/conf" do
    action :delete
    recursive true
    not_if { ::File.exist?("#{node['snoonet']['dirs']['deploy']}/conf") && ::File.symlink?("#{node['snoonet']['dirs']['deploy']}/conf") }
end

# Link the config dir
link "#{node['snoonet']['dirs']['deploy']}/conf" do
    to node['snoonet']['dirs']['confrepo']
end

# Create a dummy conf for testing if our repo location is 'test' instead of
# a proper URL
if node['snoonet']['config']['repo'] == 'test'
    file "#{node['snoonet']['dirs']['confrepo']}/inspircd.conf" do
        content <<-CONF
Dummy Config
        CONF
        action :create
    end
else
    git node['snoonet']['dirs']['confrepo'] do
        user node['snoonet']['user']
        group node['snoonet']['group']
        repository node['snoonet']['config']['repo']
        action :sync
        notifies :restart, 'service[snoonet-inspircd]', :immediately
    end
end

execute "Configure InspIRCd" do
    cwd node['snoonet']['dirs']['repo']
    user node['snoonet']['user']
    group node['snoonet']['group']
    command "./configure --prefix=#{node['snoonet']['dirs']['deploy']} --development"
    action :nothing
end

execute "Compile InspIRCd" do
    cwd node['snoonet']['dirs']['repo']
    user node['snoonet']['user']
    group node['snoonet']['group']
    # Have to include cd because of PWD wonkyness
    command "cd #{node['snoonet']['dirs']['repo']} && make -j1"
    action :nothing
end

execute "Install InspIRCd" do
    cwd node['snoonet']['dirs']['repo']
    user node['snoonet']['user']
    group node['snoonet']['group']
    command "cd #{node['snoonet']['dirs']['repo']} && make install"
    action :nothing
end

execute "Backup InspIRCd" do
    srcdir = node['snoonet']['dirs']['deploy']
    dstdir = srcdir + "-" + Time.now.strftime("%Y%m%d%H%M%S")
    user node['snoonet']['user']
    group node['snoonet']['group']
    command "mv #{srcdir} #{dstdir}"
    action :nothing
end

execute "Stop InspIRCd" do
    user node['snoonet']['user']
    group node['snoonet']['group']
    command "killall inspircd"
    action :nothing
end

# We can only create and manage services if we're root
if ENV['USER'] == 'root'
    # Setup the InspIRCd Service
    include_recipe "#{cookbook_name}::service"
end
