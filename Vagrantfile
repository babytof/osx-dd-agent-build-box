# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Building on Yosemite ensures compatibility with it as well as the next versions
  # of OSX
  config.vm.box = "http://files.dryga.com/boxes/osx-yosemite-0.2.0.box"

  # We can't use Berkshelf without synced folders... that's the reason behind
  # the mess below :/
  config.vm.provision "shell" do |s|
    s.privileged = false
    s.path = "provision.sh"
  end

  # Port forwarding
  config.vm.network "forwarded_port", guest: 1099, host: 1199
  config.vm.network :private_network, ip: '192.168.34.132'

  # Let's trigger the build !
  config.vm.provision "shell", inline: "sh ./dd-agent-omnibus/omnibus_build.sh", privileged: false

end
