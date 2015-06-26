# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Building on Yosemite ensures compatibility with it as well as the next versions
  # of OSX
  config.vm.box = "http://files.dryga.com/boxes/osx-yosemite-0.2.0.box"

  # If we have a signing key hidden in an environment variable let's pass it to
  # the vagrant machine
  if ENV.has_key?('DD_AGENT_DMG_SIGNING_CERT')
    config.vm.provision "shell", inline: "echo \"export DD_AGENT_DMG_SIGNING_CERT=\\\""\
      "#{ENV['DD_AGENT_DMG_SIGNING_CERT']}\\\"\" >> /Users/vagrant/env_passthrough.sh",
      privileged: false
  end

  # We can't use Berkshelf without synced folders... that's the reason behind
  # the mess below :/
  config.vm.provision "shell" do |s|
    s.privileged = false
    s.path = "provision.sh"
  end

  # Port forwarding
  config.vm.network "forwarded_port", guest: 1099, host: 1199
  config.vm.network :private_network, ip: '192.168.34.132'

end
