#!/bin/bash

set -e

echo "## Authenticating with nodes in cluster..."
sudo pcs cluster auth node1 node2 -u hacluster -p CHANGEME
echo "## Setting up cluster..."
sudo pcs cluster setup --name synapse node1 node2
echo "## Starting cluster..."
sudo pcs cluster start --all

echo "## Disable host-level stonith (it requires platform-specific fencing agents)"
sudo pcs property set stonith-enabled=false
# FIXME - Need to configure STONITH device on all hosts
# http://clusterlabs.org/doc/en-US/Pacemaker/1.1-pcs/html-single/Clusters_from_Scratch/index.html#idm139647334829056

# See sudo pcs resource describe ocf:heartbeat:docker for details of options
echo "## Adding docker service resource"
sudo pcs resource create \
    docker \
    systemd:docker
echo "## Adding synapse resource..."
sudo pcs resource create \
    synapse \
    ocf:heartbeat:docker \
    image="matrixdotorg/synapse:v0.22.1" \
    name="synapse" \
    run_opts="--volume /synapse/config/:/synapse/config/ --publish 8008:8008 --publish 8448:8448" \
    monitor_cmd="curl -fso /dev/null http://localhost:8008/_matrix/client/versions" \
    op monitor timeout="30" interval="30" on-fail="restart"
echo "## Start docker then synapse on the same host"
sudo pcs constraint colocation add synapse with docker INFINITY
sudo pcs constraint order docker then synapse
echo "## Enable docker and synapse"
sudo pcs resource enable docker
sudo pcs resource enable synapse
