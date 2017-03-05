#!/bin/bash
###############################################################################
METADATA_HOST=rancher-metadata.rancher.internal
METADATA_VERSION=latest
METADATA=$METADATA_HOST/$METADATA_VERSION
function metadata { echo $(curl -s $METADATA/$1); }
###############################################################################
echo $ZK_SERVICE > /tmp/ZK_SERVICE
echo $MESOS_SERVICE > /tmp/MESOS_SERVICE
MESOS_EXECUTOR_CORE=${MESOS_EXECUTOR_CORE:-0.1}
CURRENT_IP=$(hostname -i)

echo "ADD kafka user account"
./adduser.sh
ADDUSER=$(cat /tmp/ADDUSER)
SSH_USERPASS=$(cat /tmp/SSH_USERPASS)
rm -f /tmp/SSH_USERPASS

echo "create kafka environment"
cp /etc/hosts /etc/hosts.tmp
sed -i "s/.*$(hostname)/$(metadata self/container/primary_ip)\t$(hostname)/g" /etc/hosts.tmp
cp /etc/hosts.tmp /etc/hosts

su -c "/mesosconfig.sh" $(cat /tmp/ADDUSER) >> /tmp/spark.log 2>&1

CURRENT_IP=$(hostname -i)
MESOS_MASTER=$(cat /tmp/MESOS_MASTER)

echo "start kafka"
./kafkaprepare.sh
/opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties

echo "start sshd"
echo "--------------------"
echo " SSH PASSWORD - please change immediately"
echo " username: ${ADDUSER} , password: ${SSH_USERPASS}"
echo "--------------------"
/usr/sbin/sshd -D