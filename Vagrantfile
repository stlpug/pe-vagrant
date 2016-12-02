# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.define "puppetmaster", primary: true do |puppetmaster|
    # Set VM memory and cpu specs
    puppetmaster.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    # Specify box and assign a hostname
    puppetmaster.vm.box_url = "http://kristianreese.com/stlpug/stlpug-master-centos-6-x64-virtualbox.box"
    puppetmaster.vm.box = "stlpug/puppetmaster"
    puppetmaster.vm.hostname = "puppetmaster.stlpug.com"

    # Network Configs
    puppetmaster.vm.network "private_network", ip: "10.10.10.10"
    puppetmaster.vm.network "forwarded_port", guest: 8140, host: 18140
    puppetmaster.vm.network "forwarded_port", guest: 443, host: 1443

    # Run r10k
    puppetmaster.vm.provision :shell, :inline => "sudo r10k deploy environment production -pv"

  end

  # No changes above this line unless you're on the master branch
  #
  # Puppet Agent(s) config namespace 'config.vm' below this line
  # Razor Server
  config.vm.define "razor", autostart: false do |node|
    # Set VM memory and cpu specs
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 1536
      vb.cpus = 2
      
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
    end

    node.vm.box = "stlpug/puppetagent"
    node.vm.box_url = "http://kristianreese.com/stlpug/stlpug-agent-centos-6-6-x64-virtualbox.box"
    node.vm.box_download_insecure = true
    node.ssh.pty = true
    node.vm.hostname = "razor.stlpug.com"
    node.vm.network "private_network", ip: "10.10.10.100"

    # Port forwarding for installer app and console app
    node.vm.network "forwarded_port", guest: 8150, host: 8150
    node.vm.network "forwarded_port", guest: 8151, host: 8151

    # Install Puppet Agent
    node.vm.provision :shell, :inline => "sudo echo '10.10.10.10  puppetmaster puppetmaster.stlpug.com' >> /etc/hosts"
    node.vm.provision :shell, :inline => "sudo echo '10.10.10.100  razor razor.stlpug.com' >> /etc/hosts"
    node.vm.provision :shell, :inline => "sudo curl -k https://puppetmaster.stlpug.com:8140/packages/current/install.bash | sudo bash"

    # Razor pre-reqs (for development environments only; do not replicate to production)
    node.vm.provision :shell, :inline => "sudo yum install -y dnsmasq wget mlocate"
    node.vm.provision :shell, :inline => "sudo mkdir -p /var/lib/tftpboot; sudo chmod 655 /var/lib/tftpboot"
    node.vm.provision :shell, :inline => "sudo echo 'bind-interfaces' >> /etc/dnsmasq.conf"
    node.vm.provision :shell, :inline => "sudo echo 'interface=eth1' >> /etc/dnsmasq.conf"
    node.vm.provision :shell, :inline => "sudo echo 'dhcp-range=eth1,10.10.10.200,10.10.10.240,24h' >> /etc/dnsmasq.conf"
    node.vm.provision :shell, :inline => "sudo sed -i -e 's:#conf-dir:conf-dir:g' /etc/dnsmasq.conf"

    # Do not query local /etc/hosts file due to vagrant injection of host on localhost line; it messes up microkernel capability to DNS lookup
    # Instead; look for hosts in banner_add_hosts
    node.vm.provision :shell, :inline => "sudo echo 'no-hosts' >> /etc/dnsmasq.conf"
    node.vm.provision :shell, :inline => "sudo echo 'addn-hosts=/etc/banner_add_hosts' >> /etc/dnsmasq.conf"

    # expand-hosts to automatically added to simple names in a hosts-file; seems to address issue with kickstart looking for kickstart file
    node.vm.provision :shell, :inline => "sudo echo 'expand-hosts' >> /etc/dnsmasq.conf"
    node.vm.provision :shell, :inline => "sudo echo 'domain=stlpug.com' >> /etc/dnsmasq.conf"

    node.vm.provision :shell, :inline => "sudo cp /vagrant/files/razor /etc/dnsmasq.d/"
    node.vm.provision :shell, :inline => "sudo cp /vagrant/files/banner_add_hosts /etc/"
    node.vm.provision :shell, :inline => "sudo cp /vagrant/files/.bashrc /root/"
    node.vm.provision :shell, :inline => "sudo sed -i '/^PATH/c PATH=\$PATH:/opt/puppetlabs/puppet/bin' /root/.bash_profile"
    node.vm.provision :shell, :inline => "sudo chkconfig dnsmasq on"
    node.vm.provision :shell, :inline => "sudo service dnsmasq start"
    node.vm.provision :shell, :inline => "sudo wget https://s3.amazonaws.com/pe-razor-resources/undionly-20140116.kpxe -O /var/lib/tftpboot/undionly-20140116.kpxe"
    node.vm.provision :shell, :inline => "sudo /opt/puppetlabs/puppet/bin/gem install pe-razor-client"

    # Configure iptables for IP forwarding and masquerading
    node.vm.provision :shell, :inline => "sudo yum install -y system-config-firewall-base"
    node.vm.provision :shell, :inline => "sudo lokkit --default=server"
    node.vm.provision :shell, :inline => "sudo chkconfig iptables on"
    node.vm.provision :shell, :inline => "sudo service iptables restart"

    node.vm.provision :shell, :inline => "sudo echo 1 > /proc/sys/net/ipv4/ip_forward"
    node.vm.provision :shell, :inline => "sudo sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf"

    node.vm.provision :shell, :inline => "sudo iptables --flush"
    node.vm.provision :shell, :inline => "sudo iptables --table nat --flush"
    node.vm.provision :shell, :inline => "sudo iptables --delete-chain"
    node.vm.provision :shell, :inline => "sudo iptables --table nat --delete-chain"
    node.vm.provision :shell, :inline => "sudo iptables -P INPUT ACCEPT"
    node.vm.provision :shell, :inline => "sudo iptables -P FORWARD ACCEPT"
    node.vm.provision :shell, :inline => "sudo iptables -P OUTPUT ACCEPT"
    node.vm.provision :shell, :inline => "sudo iptables -I INPUT -p all -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT"
    node.vm.provision :shell, :inline => "sudo iptables --append FORWARD --in-interface eth1 --out-interface eth0 -j ACCEPT"
    node.vm.provision :shell, :inline => "sudo iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE"
    node.vm.provision :shell, :inline => "sudo service iptables save"
    node.vm.provision :shell, :inline => "sudo service iptables restart"

    # Download needed files
    node.vm.provision :shell, :inline => "sudo curl -o /tmp/razor-winpe.wim http://kristianreese.com/stlpug/razor-winpe.wim"
    node.vm.provision :shell, :inline => "sudo curl -o /tmp/win2k12r2.iso http://kristianreese.com/stlpug/win2k12r2.iso"
  end

  # Razor Client for RHEL
  config.vm.define "razornode-rhel", autostart: false do |config|
    config.vm.box_url = "http://kristianreese.com/stlpug/dummy-linux.box"
    config.vm.box = "stlpug/dummy-linux"
    config.vm.boot_timeout = 10

    config.vm.provider "virtualbox" do |rc|
      rc.gui = true
      rc.name = "razornode-rhel"
      rc.memory = 512
      rc.cpus = 1
      rc.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
      rc.customize ["modifyvm", :id, "--ostype", "RedHat_64"]
      rc.customize ["modifyvm", :id, "--ioapic", "off"]
      rc.customize ["modifyvm", :id, "--boot1", "net"]
      rc.customize ["modifyvm", :id, "--boot2", "disk"]
      rc.customize ["modifyvm", :id, "--boot3", "none"]
      rc.customize ["modifyvm", :id, "--boot4", "none"]

      # NIC 1 config (hostonly)
      rc.customize ["modifyvm", :id, "--nic1", "hostonly"]
      rc.customize ["modifyvm", :id, "--hostonlyadapter1", "vboxnet0"]
      rc.customize ["modifyvm", :id, "--macaddress1", "080027411F6F"]
    end
  end

  # Razor Client for Windows
  config.vm.define "razornode-win", autostart: false do |config|
    config.vm.box_url = "http://kristianreese.com/stlpug/dummy-win.box"
    config.vm.box = "stlpug/dummy-win"
    config.vm.boot_timeout = 10

    config.vm.provider "virtualbox" do |rc|
      rc.gui = true
      rc.name = "razornode-win2k12r2"
      rc.memory = 768
      rc.cpus = 1
      rc.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
      rc.customize ["modifyvm", :id, "--ostype", "Windows2012_64"]
      rc.customize ["modifyvm", :id, "--ioapic", "on"]
      rc.customize ["modifyvm", :id, "--boot1", "net"]
      rc.customize ["modifyvm", :id, "--boot2", "disk"]
      rc.customize ["modifyvm", :id, "--boot3", "none"]
      rc.customize ["modifyvm", :id, "--boot4", "none"]

      # NIC 1 config (hostonly)
      rc.customize ["modifyvm", :id, "--nic1", "hostonly"]
      rc.customize ["modifyvm", :id, "--hostonlyadapter1", "vboxnet0"]
      rc.customize ["modifyvm", :id, "--macaddress1", "080027CA0EDB"]
    end
  end

  # Razor Client for ESXi
  config.vm.define "razornode-esxi", autostart: false do |config|
    config.vm.box_url = "http://kristianreese.com/stlpug/dummy-esxi.box"
    config.vm.box = "stlpug/dummy-esxi"
    config.vm.boot_timeout = 10

    config.vm.provider "virtualbox" do |rc|
      rc.gui = true
      rc.name = "razornode-esxi"
      rc.memory = 4096
      rc.cpus = 1
      rc.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
      rc.customize ["modifyvm", :id, "--ostype", "RedHat_64"]
      rc.customize ["modifyvm", :id, "--ioapic", "on"]
      rc.customize ["modifyvm", :id, "--boot1", "net"]
      rc.customize ["modifyvm", :id, "--boot2", "disk"]
      rc.customize ["modifyvm", :id, "--boot3", "none"]
      rc.customize ["modifyvm", :id, "--boot4", "none"]

      # NIC 1 config (hostonly)
      rc.customize ["modifyvm", :id, "--nic1", "hostonly"]
      rc.customize ["modifyvm", :id, "--hostonlyadapter1", "vboxnet0"]
      rc.customize ["modifyvm", :id, "--macaddress1", "080027DF3DC8"]
    end
  end

end
