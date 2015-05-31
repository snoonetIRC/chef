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
user default['snoonet']['user'] do
    action :create
end

# Create the directories the repo and deploy will live in
directories = %W(
    #{node['snoonet']['inspircd']['srcdir']}
    #{node['snoonet']['inspircd']['deploydir']}
)
directories.each { |dir|
    directory dir do
        owner default['snoonet']['user']
        group default['snoonet']['group']
        action :create
        recursive true
    end
}

# Sync the repo with git
git node['snoonet']['inspircd']['srcdir'] do
    user default['snoonet']['user']
    group default['snoonet']['group']
    repository node['snoonet']['inspircd']['repo']
    action :sync
end

execute "Run configure" do
    cwd node['snoonet']['inspircd']['srcdir']
    user default['snoonet']['user']
    group default['snoonet']['group']
    command "./configure --prefix=#{node['snoonet']['inspircd']['deploydir']} --development"
    action :run
end

execute "Compile InspIRCd" do
    cwd node['snoonet']['inspircd']['srcdir']
    user default['snoonet']['user']
    group default['snoonet']['group']
    # Have to include cd because of PWD wonkyness
    command "cd #{node['snoonet']['inspircd']['srcdir']} && make -j1"
    action :run
end

execute "Install InspIRCd" do
    cwd node['snoonet']['inspircd']['srcdir']
    user default['snoonet']['user']
    group default['snoonet']['group']
    command "cd #{node['snoonet']['inspircd']['srcdir']} && make install"
    action :run
end
