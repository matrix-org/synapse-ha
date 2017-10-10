# synapse active-passive with automated failover

## Status

* The Vagrantfile creates two nodes and configures pacemaker/corosync for active-passive
* Host-level STONITH (shoot the other node in the head) fencing requires external 'stonith devices' supporting by fencing agents. This is not done and host-level STONITH is disabled currently. See http://clusterlabs.org/doc/en-US/Pacemaker/1.1-pcs/html-single/Clusters_from_Scratch/index.html#idm139647334829056 and `yum search fence-` for details and options respectively.
* If one kills the synapse container, it will be restarted on one of the nodes in the cluster. If one stops the docker daemon, for some reason it gets restarted but the synapse container gets stuck in a stopped state. To 'reset' it and get the synapse container to start again, for some reason one needs to run `sudo pcs resource cleanup synapse` on one of the nodes.
* Read through the notes in `Vagrantfile`, `bootstrap.sh` and `node1.sh`
* Many parts like IP addresses have been hard-coded for testing.

## Running

In this directory:

* `vagrant up` - creates the two centos 7 VMs as per the `Vagrantfile` and runs the `bootstrap.sh` provisioning script on each node
* `vagrant ssh node1` - ssh into node1, then run `/vagrant/node1.sh` to run the commands that have to be run on one of the nodes to configure the cluster
* `vagrant ssh node2` - to ssh into node2 if you wish

Useful commands that can be run on a node:
* `sudo pcs status` - shows the status of the cluster in terms of nodes and resources
* `sudo pcs cluster standby node1` - put node1 into standby mode which should demonstrate migration of resources to node2
* `sudo pcs cluster unstandby node1` - to make node1 available again
* `sudo pcs resource cleanup synapse` - in case the synapse resource gets stuck in a stopped state

## To do

* The synapse resource may get stuck in the Stopped state and require manual intervention by running `sudo pcs resource cleanup synapse` to get it running again
* Configuration against a postgres database (see synapse docker image readme for details)
* Synchronise configuration between nodes (currently duplicated per node - **modifications to synapse configuration on one node are not carried over to other nodes**)
* Convenient packaging as 'appliance'-type VM images with some way of setting a few parameters to configure the instances
