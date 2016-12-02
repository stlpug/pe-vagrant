# Get bootstrap
wget 'https://vgtrazor.stlpug.com:8151/api/microkernel/bootstrap?nic_max=1&http_port=8150' --no-check-certificate -O /var/lib/tftpboot/bootstrap.ipxe

# Create Razor Repo
razor create-repo --name centos6 --task centos --iso-url http://archive.kernel.org/centos-vault/6.6/isos/x86_64/CentOS-6.6-x86_64-minimal.iso
razor create-repo --name win2k12r2 --task windows/2012r2 --no-content
razor create-repo --name win2k8r2 --task windows/2008r2 --no-content

# Create Razor Broker:
razor create-broker --name pe --broker-type puppet-pe --configuration server=puppetmaster.stlpug.com

# Create Razor Policy:
razor create-policy --name centos6 --repo centos6 --task centos --broker pe --enabled --hostname 'apache1' --root-password secret
razor create-policy --name win2k12r2 --repo win2k12r2 --task windows/2012r2 --broker pe --enabled --hostname 'win2k12r2${id}.stlpug.com' --root-password secret
razor create-policy --name win2k8r2 --repo win2k8r2 --task windows/2008r2 --broker pe --enabled --hostname 'win2k8r2${id}.stlpug.com' --root-password secret
