#
# Cookbook Name:: dd-agent-osx-build-box
# Recipe:: default
#
# Copyright 2015, Datadog Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe "omnibus"

# Let's setup some permissions here and there and have fun
execute "tweak-omnibus-permissions" do
    command "sudo mkdir -p /var/cache/omnibus /opt/datadog-agent && \
        sudo chown -R vagrant:nogroup /var/cache/omnibus /opt/datadog-agent"
end
