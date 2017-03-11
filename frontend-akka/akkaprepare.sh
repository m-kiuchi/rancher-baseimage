#!/bin/bash
###############################################################################
METADATA_HOST=rancher-metadata.rancher.internal
METADATA_VERSION=latest
METADATA=$METADATA_HOST/$METADATA_VERSION
function metadata { echo $(curl -s $METADATA/$1); }
###############################################################################

ZK_STRING=$(cat /tmp/ZK_STRING)
ADDUSER=$(cat /tmp/ADDUSER)

echo 'export PATH="${PATH}:/opt/activator/bin"' >> ~/.bashrc

