
# Snoonet user information
default['snoonet']['user'] = 'snoonet'
default['snoonet']['group'] = 'snoonet'

# Set the repo location
default['snoonet']['inspircd']['repo'] = 'https://github.com/inspircd/inspircd.git'

# Local source dir
default['snoonet']['inspircd']['srcdir'] = '/home/snoonet/src/inspircd'
default['snoonet']['inspircd']['deploydir'] = '/home/snoonet/inspircd'

# Local config dir
default['snoonet']['config']['srcdir'] = '/home/snoonet/src/inspconf'
default['snoonet']['config']['deploylink'] = "#{node['snoonet']['inspircd']['deploydir']}/conf"
