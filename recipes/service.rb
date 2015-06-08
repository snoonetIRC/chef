# Setup the InspIRCd service

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
    action :start
end
