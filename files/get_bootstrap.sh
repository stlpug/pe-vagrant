# Get bootstrap.ipxe
wget 'https://razor.stlpug.com:8151/api/microkernel/bootstrap?nic_max=1&http_port=8150' --no-check-certificate -O /var/lib/tftpboot/bootstrap.ipxe

# Create Razor Broker:
razor create-broker --name pe --broker-type puppet-pe --configuration server=puppetmaster.stlpug.com
razor create-broker --name=noop --broker-type=noop

# Create Razor Repo:
razor create-repo --name centos6 --task centos --iso-url "http://archive.kernel.org/centos-vault/6.6/isos/x86_64/CentOS-6.6-x86_64-minimal.iso"
razor create-repo --name win2k12r2 --task windows/2012r2 --no-content
razor create-repo --name win2k8r2 --task windows/2008r2 --no-content
razor create-repo --name esxi6 --task vmware_esxi --iso-url "http://kristianreese.com/stlpug/Vmware-ESXi-6.0.0-3620759-Custom-Cisco-6.0.2.1.iso"

# Create Razor Policy:
razor create-policy --name centos6 --repo centos6 --task centos --broker pe --enabled --hostname 'apache1' --root-password secret
razor create-policy --name win2k12r2 --repo win2k12r2 --task windows/2012r2 --broker pe --enabled --hostname 'win2k12r2${id}.stlpug.com' --root-password secret
razor create-policy --name win2k8r2 --repo win2k8r2 --task windows/2008r2 --broker pe --enabled --hostname 'win2k8r2${id}.stlpug.com' --root-password secret
razor create-policy --name esxi6 --repo esxi6 --task vmware_esxi --broker noop --enabled --hostname 'esxi${id}.stlpug.com' --root-password secret

