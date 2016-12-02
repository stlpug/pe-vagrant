#!/bin/bash

echo "Step 1: Deactivate the agent"
for node in $@; do puppet node purge $node; done

echo "Step 2: invoke Puppet run to copy the cert revocation list (CRL) to the correct SSL directory"
puppet agent -t

echo "Step 3: Restart Puppet master.  The Puppet server process won't re-read the cert revocation list until the service is restarted"
service pe-puppetserver restart
