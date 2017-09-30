#!/bin/bash

set -e

# docker-ce
yum -y install \
    yum-utils \
    device-mapper-persistent-data \
    lvm2

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum -y install \
    docker-ce

# pacemaker / corosync
yum -y install \
    pacemaker \
    pcs \
    resource-agents

# debug utilities
yum -y install \
    nc \
    vim

# configure each node's hacluster user password
# NOTE: this password should be changed!
echo CHANGEME | passwd --stdin hacluster

# call them node1 and node2 and give them hostnames
# FIXME - this could be handled much better with DNS
(cat >> /etc/hosts) <<EOF

192.168.1.151   node1
192.168.1.152   node2

EOF

# start the docker daemon so that the docker group gets created
systemctl start docker.service
# make the vagrant user a member of the docker group to be able to issue docker commands
# NOTE: this is only for debug purposes - testing by killing docker containers
usermod -a -G docker vagrant

# run a temporary synapse container to generate the configuration
# see https://github.com/matrix-org/synapse/pull/2482 and https://github.com/matrix-org/synapse/blob/24d162814bc8c9ba05bfecac04e7218baebf2859/docker/README.md for details
# NOTE: the following configuration will need to be changed!
CONFIG_PATH="/synapse/config/"
SERVER_NAME="localhost"
mkdir -p ${CONFIG_PATH}
docker run \
    --rm \
    -e GENERATE_CONFIG=yes \
    -e REPORT_STATS=yes \
    -e SERVER_NAME="${SERVER_NAME}" \
    -v ${CONFIG_PATH}:/synapse/config/ \
    matrixdotorg/synapse:v0.22.1

# stop and make sure the docker daemon service is disabled as it will be managed by pacemaker
systemctl stop docker.service
systemctl disable docker.service

# start the pcsd service to allow running pcs commands
systemctl start pcsd.service
systemctl enable pcsd.service
