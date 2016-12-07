# pe-vagrant
Puppet Enterprise Master and Agents

## Usage
###### Deploy a puppet master:
```
vagrant up puppetmaster
```

***

###### Linux Agent Nodes
To create a puppet agent node, first create a branch off master relative to the body of work.  For example, to create an agent node to test the puppetlabs/apache module, create a branch named 'apache'.
```
git checkout -b apache
```

Within the apache branch, add the following to the Vagrantfile immediately after the following comment within the puppetmaster define block:

`# Puppet Agent(s) config namespace 'config.vm' below this line`

```
  # Puppet Agent(s) config namespace 'config.vm' below this line
  config.vm.define "apache" do |node|
    node.vm.box_url = "http://kristianreese.com/stlpug/stlpug-agent-centos-6-6-x64-virtualbox.box"
    node.vm.box = "stlpug/puppetagent"
    node.vm.hostname = "apache.stlpug.com"

    node.vm.network "private_network", ip: "10.10.10.100"

    node.ssh.pty = true
    node.vm.provision :shell, :inline => "sudo echo '10.10.10.10  puppetmaster puppetmaster.stlpug.com' >> /etc/hosts"
    node.vm.provision :shell, :inline => "sudo echo '10.10.10.100  apache apache.stlpug.com' >> /etc/hosts"
    node.vm.provision :shell, :inline => "sudo curl -k https://puppetmaster.stlpug.com:8140/packages/current/install.bash | sudo bash"
  end
```

To create the apache puppet agent node:
```
vagrant up apache
```

As long as the puppetmaster is up and running, the agent node will bootstrap the puppet agent and be ready for testing.

***

###### Windows Agent Nodes
COMING SOON
