#
# Cookbook Name:: snoonet-deploy
# Recipe:: default
#
# Copyright (C) 2015 SnooNet
#
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
    action :create
end

# Create the directories the repo and deploy will live in
directories = %W(
    #{node['snoonet']['inspircd']['srcdir']}
    #{node['snoonet']['inspircd']['deploydir']}
    #{node['snoonet']['config']['srcdir']}
)
directories.each { |dir|
    directory dir do
        owner node['snoonet']['user']
        group node['snoonet']['group']
        action :create
        recursive true
    end
}

# Sync the repo with git
git node['snoonet']['inspircd']['srcdir'] do
    user node['snoonet']['user']
    group node['snoonet']['group']
    repository node['snoonet']['inspircd']['repo']
    action :sync
    notifies :run, 'execute[Run configure]', :immediately
    notifies :run, 'execute[Compile InspIRCd]', :immediately
    notifies :run, 'execute[Install InspIRCd]', :immediately
end

execute "Run configure" do
    cwd node['snoonet']['inspircd']['srcdir']
    user node['snoonet']['user']
    group node['snoonet']['group']
    command "./configure --prefix=#{node['snoonet']['inspircd']['deploydir']} --development"
    action :nothing
end

execute "Compile InspIRCd" do
    cwd node['snoonet']['inspircd']['srcdir']
    user node['snoonet']['user']
    group node['snoonet']['group']
    # Have to include cd because of PWD wonkyness
    command "cd #{node['snoonet']['inspircd']['srcdir']} && make -j1"
    action :nothing
end

execute "Install InspIRCd" do
    cwd node['snoonet']['inspircd']['srcdir']
    user node['snoonet']['user']
    group node['snoonet']['group']
    command "cd #{node['snoonet']['inspircd']['srcdir']} && make install"
    action :nothing
end

file '/etc/init/snoonet-inspircd.conf' do
    content <<-FILE
description "Snoonet's InspIRCd Daemon"

start on runlevel [2345]
stop on runlevel [!2345]

setuid snoonet
setgid snoonet

exec #{node['snoonet']['inspircd']['deploydir']}/bin/inspircd --config=#{node['snoonet']['config']['deploylink']}/inspircd.conf
    FILE
    action :create
end

service 'snoonet-inspircd' do
    action [ :enable, :start ]
end
