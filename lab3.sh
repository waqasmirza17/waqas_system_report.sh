#!/usr/bin/env bash
#
# Lab3.sh script
set -e

VERBOSE_FLAG=""
if [[ "$1" == "-verbose" ]]; then
  VERBOSE_FLAG="-verbose"
fi
echo "Copying configure-host.sh to server1..."
scp configure-host.sh remoteadmin@server1-mgmt:/root/configure-host.sh

echo "Copying configure-host.sh to server2..."
scp configure-host.sh remoteadmin@server2-mgmt:/root/configure-host.sh

echo "Configuring server1..."
ssh remoteadmin@server1-mgmt -- /root/configure-host.sh $VERBOSE_FLAG \
  -name loghost \
  -ip 192.168.16.3 \
  -hostentry webhost 192.168.16.4

echo "Configuring server2..."
ssh remoteadmin@server2-mgmt -- /root/configure-host.sh $VERBOSE_FLAG \
  -name webhost \
  -ip 192.168.16.4 \
  -hostentry loghost 192.168.16.3

echo "Updating local /etc/hosts for the two servers..."
./configure-host.sh $VERBOSE_FLAG -hostentry loghost 192.168.16.3
./configure-host.sh $VERBOSE_FLAG -hostentry webhost 192.168.16.4

echo "All done."
