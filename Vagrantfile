# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.define "puppetmaster" do |puppetmaster|
    # Set VM memory and cpu specs
    puppetmaster.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    # Specify box and assign a hostname
    puppetmaster.vm.box_url = "http://kristianreese.com/stlpug/stlpug-centos-6-6-x64-virtualbox.box"
    puppetmaster.vm.box = "stlpug/puppetmaster"
    puppetmaster.vm.hostname = "puppetmaster"

    # Network Configs
    puppetmaster.vm.network "private_network", ip: "10.10.10.10"
    puppetmaster.vm.network "forwarded_port", guest: 8140, host: 18140
    puppetmaster.vm.network "forwarded_port", guest: 443, host: 1443

  end
end
