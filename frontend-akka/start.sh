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

echo "ADD akka user account"
if [ "$1" != "" ]; then
  ./adduser.sh $1
else
  ./adduser.sh
fi
ADDUSER=$(cat /tmp/ADDUSER)
SSH_USERPASS=$(cat /tmp/SSH_USERPASS)
rm -f /tmp/SSH_USERPASS

echo "create mesos config"
CURRENT_IP=$(hostname -i)
su -c "/mesosconfig.sh" $(cat /tmp/ADDUSER) >> /tmp/spark.log 2>&1
MESOS_MASTER=$(cat /tmp/MESOS_MASTER)

echo "create akka config"
cat > /etc/profile.d/akka.sh <<EOT
# Akka framework
export PATH="${PATH}:/opt/activator/bin"
EOT

echo "start sshd"
echo "--------------------"
echo " SSH PASSWORD - please change immediately"
echo " username: ${ADDUSER} , password: ${SSH_USERPASS}"
echo "--------------------"
/usr/sbin/sshd -D
