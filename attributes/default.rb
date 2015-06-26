default['go']['filename'] = "go#{node['go']['version']}.#{node['os']}-#{node['go']['platform']}-osx10.8.tar.gz"
default['go']['url'] = "https://storage.googleapis.com/golang/#{node['go']['filename']}"
