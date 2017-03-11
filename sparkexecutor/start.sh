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

echo "ADD spark user account"
if [ "$1" != "" ]; then
  ./adduser.sh $1
else
  ./adduser.sh
fi
ADDUSER=$(cat /tmp/ADDUSER)
SSH_USERPASS=$(cat /tmp/SSH_USERPASS)
rm -f /tmp/SSH_USERPASS

echo "create spark environment"
cp /etc/hosts /etc/hosts.tmp
sed -i "s/.*$(hostname)/$(metadata self/container/primary_ip)\t$(hostname)/g" /etc/hosts.tmp
cp /etc/hosts.tmp /etc/hosts

su -c "/mesosconfig.sh" $(cat /tmp/ADDUSER) >> /tmp/spark.log 2>&1

CURRENT_IP=$(hostname -i)
MESOS_MASTER=$(cat /tmp/MESOS_MASTER)
MARATHON_MASTER=$(cat /tmp/MARATHON_MASTER)
export SPARK_LOCAL_IP=${SPARK_LOCAL_IP:-${CURRENT_IP:-"127.0.0.1"}}
echo "spark.master                      ${MESOS_MASTER}" >> /opt/spark/conf/spark-defaults.conf
echo "spark.mesos.executor.docker.image mkiuchicl/sparkexecutor" >> /opt/spark/conf/spark-defaults.conf
echo "spark.mesos.executor.home         /opt/spark" >> /opt/spark/conf/spark-defaults.conf
echo "spark.mesos.mesosExecutor.cores   ${MESOS_EXECUTOR_CORE}" >> /opt/spark/conf/spark-defaults.conf
echo "spark.driver.host                 ${CURRENT_IP}" >> /opt/spark/conf/spark-defaults.conf

cat > /opt/spark/conf/spark-env.sh <<EOT
#!/usr/bin/env bash
export MESOS_NATIVE_JAVA_LIBRARY=${MESOS_NATIVE_JAVA_LIBRARY:-/usr/lib/libmesos.so}
export SPARK_LOCAL_IP=${SPARK_LOCAL_IP:-"127.0.0.1"}
EOT

cat > /etc/profile.d/spark.sh <<EOT
# Apache Spark
export SPARK_HOME=/opt/spark
export MESOS_MASTER=${MESOS_MASTER}
export MARATHON_MASTER=${MARATHON_MASTER}
alias spark-shell="sudo /opt/spark/bin/spark-shell --master '${MESOS_MASTER}'"
alias spark-submit="sudo /opt/spark/bin/spark-submit --master '${MESOS_MASTER}' --supervise"
EOT

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
/usr/sbin/sshd -D &

exec "$@"

