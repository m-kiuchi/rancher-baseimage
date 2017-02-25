#!/bin/bash
echo $ZK_SERVICE > /tmp/ZK_SERVICE
echo $MESOS_SERVICE > /tmp/MESOS_SERVICE
echo $CAS_TYPE > /tmp/CAS_TYPE

echo "ADD cassandra user account"
./adduser.sh
ASSUSER=$(cat /tmp/ADDUSER)
SSH_USERPASS=$(cat /tmp/SSH_USERPASS)
rm -f /tmp/SSH_USERPASS

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
