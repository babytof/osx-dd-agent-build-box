build_user = 'omnibus'

if ENV['OMNIBUS_USER']
  build_user = ENV['OMNIBUS_USER']
else
  build_user = ENV['USER'] || 'omnibus'
end

default['omnibus']['build_user'] = build_user
default['omnibus']['build_user_group'] = 'admin'
default['omnibus']['install_dir'] = '/opt/datadog-agent'
