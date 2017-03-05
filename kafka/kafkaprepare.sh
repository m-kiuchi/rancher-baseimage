#!/bin/bash
###############################################################################
METADATA_HOST=rancher-metadata.rancher.internal
METADATA_VERSION=latest
METADATA=$METADATA_HOST/$METADATA_VERSION
function metadata { echo $(curl -s $METADATA/$1); }
###############################################################################

MYINDEX=$(metadata self/service/create_index)
MYPORT=$(expr 9091 + $MYINDEX)
MYHOST=$(hostname -i)

cat /opt/kafka/config/server.properties |sed -e "s/broker.id=0/broker.id=${MYINDEX}/" > 1
cat 1 | sed -e "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/:${MYPORT}/" > 2
mv 2 /opt/kafka/config/server.properties
rm -f 1
