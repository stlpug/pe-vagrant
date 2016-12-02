# Get bootstrap.ipxe
echo 'Downloading bootstrap.ipxe from Razor server. . .'
wget 'https://razor.stlpug.com:8151/api/microkernel/bootstrap?nic_max=1&http_port=8150' --no-check-certificate -O /var/lib/tftpboot/bootstrap.ipxe

# Create Razor Broker:
echo 'Creating brokers. . .'
razor create-broker --name pe --broker-type puppet-pe --configuration server=puppetmaster.stlpug.com
razor create-broker --name=noop --broker-type=noop

# Create Razor Repo:
echo 'Creating repos. . .'
razor create-repo --name centos6 --task centos --iso-url "http://archive.kernel.org/centos-vault/6.6/isos/x86_64/CentOS-6.6-x86_64-minimal.iso"
razor create-repo --name win2k12r2 --task windows/2012r2 --no-content
razor create-repo --name win2k8r2 --task windows/2008r2 --no-content
razor create-repo --name esxi6 --task vmware_esxi --iso-url "http://kristianreese.com/stlpug/Vmware-ESXi-6.0.0-3620759-Custom-Cisco-6.0.2.1.iso"

# Create Razor Tag:
echo 'Creating tags. . .'
razor create-tag --name centos6 --rule '["has_macaddress", "08:00:27:41:1f:6f"]'
razor create-tag --name win2k12r2 --rule '["has_macaddress", "08:00:27:ca:0e:db"]'

# Create Razor Policy:
echo 'Creating policies. . .'
razor create-policy --name centos6 --repo centos6 --task centos --broker pe --enabled --hostname 'apache${id}.stlpug.com' --root-password secret --tag centos6
razor create-policy --name win2k12r2 --repo win2k12r2 --task windows/2012r2 --broker pe --enabled --hostname 'win2k12r2${id}.stlpug.com' --root-password secret --tag win2k12r2
razor create-policy --name win2k8r2 --repo win2k8r2 --task windows/2008r2 --broker pe --enabled --hostname 'win2k8r2${id}.stlpug.com' --root-password secret
razor create-policy --name esxi6 --repo esxi6 --task vmware_esxi --broker noop --enabled --hostname 'esxi${id}.stlpug.com' --root-password secret

# Prep for Windows deployment:
echo 'Exracting Windows ISO to repo directory. . .'
mount -o loop /tmp/win2k12r2.iso /mnt/
cd /mnt
cp -R . /opt/puppetlabs/server/data/razor-server/repo/win2k12r2/
echo 'Copying wim file to repo directory. . .'
cp /tmp/razor-winpe.wim /opt/puppetlabs/server/data/razor-server/repo/win2k12r2/

echo 'Done.'
