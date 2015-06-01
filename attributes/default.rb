# Snoonet user information
default['snoonet']['user'] = 'snoonet'
default['snoonet']['group'] = 'snoonet'
default['snoonet']['homedir'] = '/home/snoonet'

# Directories
default['snoonet']['dirs']['deploy'] = "#{node['snoonet']['homedir']}/inspircd"
default['snoonet']['dirs']['srcroot'] = "#{node['snoonet']['homedir']}/src"
default['snoonet']['dirs']['repo'] = "#{node['snoonet']['dirs']['srcroot']}/inspircd"
default['snoonet']['dirs']['confrepo'] = "#{node['snoonet']['dirs']['srcroot']}/inspconf"

# Local source dir
default['snoonet']['inspircd']['repo'] = 'https://github.com/inspircd/inspircd.git'

# Local config info
default['snoonet']['config']['repo'] = 'snoonet@con.cosmos.snoonet.org:~/git/inspconf'
