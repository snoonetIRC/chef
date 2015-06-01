#
# Cookbook Name:: snoonet-deploy
# Recipe:: default
#
# Copyright (C) 2015 SnooNet
#

# We can only install packages and create users if we're root
if ENV['USER'] == 'root'
    # Update apt-get because sometimes it behaves poorly

    execute "apt-get update" do
        command "apt-get update"
    end

    # Install packages
    packages = %w(
        git
        clang
        pkg-config
        libssl-dev
    )

    packages.each { |pkg|
        package pkg do
            action :install
        end
    }

    # Ensure the default snoonet user exists
    user node['snoonet']['user'] do
        supports :manage_home => true
        home node['snoonet']['homedir']
        action :create
    end

    # Define parameters
    inspircdstop = [:stop, 'service[snoonet-inspircd]', :immediately]
    inspircdrestart = [:restart, 'service[snoonet-inspircd]', :immediately]
else
    inspircdstop = [:run, 'execute[Stop InspIRCd]', :immediately]
    inspircdrestart = [:run, 'execute[Restart InspIRCd', :immediately]
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

=begin
git node['snoonet']['config']['srcdir'] do
    user node['snoonet']['user']
    group node['snoonet']['group']
    repository node['snoonet']['config']['repo']
    action :sync
    notifies :restart, 'service[snoonet-inspircd]', :immediately
end
=end

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
    file '/etc/init/snoonet-inspircd.conf' do
        content <<-FILE
    description "Snoonet's InspIRCd Daemon"

    start on runlevel [2345]
    stop on runlevel [!2345]

    setuid snoonet
    setgid snoonet

    exec #{node['snoonet']['dirs']['deploy']}/bin/inspircd --config=#{node['snoonet']['dirs']['deploy']}/conf/inspircd.conf
        FILE
        action :create
    end

    service 'snoonet-inspircd' do
        action [ :enable, :start ]
    end
end
