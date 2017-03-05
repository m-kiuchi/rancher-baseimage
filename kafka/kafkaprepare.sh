#!/bin/bash
###############################################################################
METADATA_HOST=rancher-metadata.rancher.internal
METADATA_VERSION=latest
METADATA=$METADATA_HOST/$METADATA_VERSION
function metadata { echo $(curl -s $METADATA/$1); }
###############################################################################

MYINDEX=$(metadata self/container/create_index)
MYPORT=$(expr 9091 + $MYINDEX)
MYHOST=$(hostname -i)
ZK_STRING=$(cat /tmp/ZK_STRING)
ADDUSER=$(cat /tmp/ADDUSER)

cat /opt/kafka/config/server.properties |sed -e "s/broker.id=0/broker.id=${MYINDEX}/" > 1
cat 1 | sed -e "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/:${MYPORT}/" > 2
cat 2 | sed -e "s/zookeeper.connect=localhost:2181/zookeeper.connect=${ZK_STRING}/" > 3
mv 3 /opt/kafka/config/server.properties
rm -f 1 2

echo 'alias kafka-topics="sudo /opt/kafka/bin/kafka-topics.sh --zookeeper '${ZK_STRING}'"' >> /home/${ADDUSER}/.bashrc
echo 'alias kafka-preferred-replica-election="sudo /opt/kafka/bin/kafka-preferred-replica-election.sh --zookeeper '${ZK_STRING}'"' >> /home/${ADDUSER}/.bashrc
