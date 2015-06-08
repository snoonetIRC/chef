# Configure the system environment for setup
# Requires root

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

