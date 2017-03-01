#!/bin/bash
###############################################################################
METADATA_HOST=rancher-metadata.rancher.internal
METADATA_VERSION=latest
METADATA=$METADATA_HOST/$METADATA_VERSION
function metadata { echo $(curl -s $METADATA/$1); }
###############################################################################
echo $ZK_SERVICE > /tmp/ZK_SERVICE
echo $MESOS_SERVICE > /tmp/MESOS_SERVICE

echo "ADD spark user account"
./adduser.sh
ADDUSER=$(cat /tmp/ADDUSER)
SSH_USERPASS=$(cat /tmp/SSH_USERPASS)
rm -f /tmp/SSH_USERPASS

echo "create spark environment"
cp /etc/hosts /etc/hosts.tmp
sed -i "s/.*$(hostname)/$(metadata self/container/primary_ip)\t$(hostname)/g" /etc/hosts.tmp
cp /etc/hosts.tmp /etc/hosts

su -c "/mesosconfig.sh" $(cat /tmp/ADDUSER) >> /tmp/spark.log 2>&1

MESOS_MASTER=$(cat /tmp/MESOS_MASTER)
CURRENT_IP=$(hostname -i)
export SPARK_LOCAL_IP=${SPARK_LOCAL_IP:-${CURRENT_IP:-"127.0.0.1"}}
echo "spark.master                      ${MESOS_MASTER}" >> /opt/spark/conf/spark-defaults.conf
echo "spark.mesos.executor.docker.image mkiuchicl/sparkdriver" >> /opt/spark/conf/spark-defaults.conf
echo "spark.mesos.executor.home         /opt/spark" >> /opt/spark/conf/spark-defaults.conf

cat > /opt/spark/conf/spark-env.sh <<EOT
#!/usr/bin/env bash
export MESOS_NATIVE_JAVA_LIBRARY=${MESOS_NATIVE_JAVA_LIBRARY:-/usr/lib/libmesos.so}
export SPARK_LOCAL_IP=${SPARK_LOCAL_IP:-"127.0.0.1"}
export SPARK_PUBLIC_DNS=${SPARK_PUBLIC_DNS:-"127.0.0.1"}
EOT

echo "start sshd"
echo "--------------------"
echo " SSH PASSWORD - please change immediately"
echo " username: ${ADDUSER} , password: ${SSH_USERPASS}"
echo "--------------------"
/usr/sbin/sshd -D
