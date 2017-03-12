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

# save my stackname and CAS_TYPE
STACK_NAME=$(metadata self/stack/name)
SEED_IP=$(metadata stacks/${STACK_NAME}/services/seed/containers/0/primary_ip)
echo $SEED_IP > /tmp/SEED_IP
echo $CAS_TYPE > /tmp/CAS_TYPE

echo "ADD cassandra user account"
./adduser.sh
ADDUSER=$(cat /tmp/ADDUSER)
SSH_USERPASS=$(cat /tmp/SSH_USERPASS)
rm -f /tmp/SSH_USERPASS

echo "create cassandra config"
cat > /etc/profile.d/cassandra.sh <<EOT
# Apache Cassandra
export PATH="${PATH}:/opt/cassandra/bin"
EOT

echo "start cassandra"
while :; do
    su -c '/cassandra.sh' $(cat /tmp/ADDUSER) > /tmp/cassandra.log 2>&1
    if [ "${CAS_TYPE}" = "seed" ]; then
        break
    else
        sleep 30
        RET=`grep "state jump to NORMAL" /tmp/cassandra.log`
        if [ "${RET}" != "" ]; then
            break
        fi
    fi
done

echo "start sshd"
echo "--------------------"
echo " SSH PASSWORD - please change immediately"
echo " username: ${ADDUSER} , password: ${SSH_USERPASS}"
echo "--------------------"
/usr/sbin/sshd -D
