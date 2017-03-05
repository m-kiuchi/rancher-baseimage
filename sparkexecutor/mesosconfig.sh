#!/bin/bash
###############################################################################
METADATA_HOST=rancher-metadata.rancher.internal
METADATA_VERSION=latest
METADATA=$METADATA_HOST/$METADATA_VERSION
function metadata { echo $(curl -s $METADATA/$1); }
###############################################################################

if [ -e /tmp/PRINCIPAL ]; then
   PRINCIPAL=$(cat /tmp/PRINCIPAL)
fi
if [ "${PRINCIPAL}" = "" ]; then
   PRINCIPAL=root
fi

if [ -e /tmp/ZK_SERVICE ]; then
   ZK_SERVICE=$(cat /tmp/ZK_SERVICE)
fi
if [ "${ZK_SERVICE}" = "" ]; then
   ZK_SERVICE="mesos/zookeeper"
fi

if [ -e /tmp/MESOS_SERVICE ]; then
   MESOS_SERVICE=$(cat /tmp/MESOS_SERVICE)
fi
if [ "${MESOS_SERVICE}" = "" ]; then
   MESOS_SERVICE="mesos/mesos-master"
fi

function zk_service {
  IFS='/' read -ra ZK <<< "$ZK_SERVICE"
  echo $(metadata stacks/${ZK[0]}/services/${ZK[1]}/$1)
}

if [ "$(zk_service containers)" == "Not found" ]; then
  echo "A zookeeper ensemble is required, but '$ZK_SERVICE' was not found."
  #sleep 1 && exit 1
fi

function zk_container_primary_ip {
  IFS='=' read -ra c <<< "$1"
  echo $(zk_service containers/${c[1]}/primary_ip)
}

function zk_string {
  ZK_STRING=
  for container in $(zk_service containers); do
    ip=$(zk_container_primary_ip $container)
    if [ "$ZK_STRING" == "" ]; then
      ZK_STRING=zk://$ip:2181
    else
      ZK_STRING=$ZK_STRING,$ip:2181
    fi
  done
  echo ${ZK_STRING}
}

function mesos_stack {
  IFS='/' read -ra MS <<< "$MESOS_SERVICE"
  #echo ${MS[0]}
  MESOS_MASTER_IP=$(metadata stacks/${MS[0]}/services/${MS[1]}/containers/0/primary_ip)
  MESOS_MASTER_PORT=$(metadata stacks/${MS[0]}/services/${MS[1]}/containers/0/ports/0/ | awk -F: '{print $2}')
}

mesos_stack
zk=$(zk_string)
export MARATHON_MASTER=$zk/$(mesos_stack)
#export MESOS_MASTER=mesos://$zk/mesos
export MESOS_MASTER=mesos://${MESOS_MASTER_IP}:${MESOS_MASTER_PORT}
if [ "${MESOS_MASTER}" = "" ]; then
  echo "$0: No Mesos Config found. Exitting."
  exit 1
else
  echo "export MESOS_MASTER=${MESOS_MASTER}" >> ~/.bashrc
  echo "export MARATHON_MASTER=${MARATHON_MASTER}" >> ~/.bashrc
  echo "${MESOS_MASTER}" > /tmp/MESOS_MASTER
fi
export MARATHON_ZK=$zk/$(metadata self/stack/name)
export MARATHON_HOSTNAME=$(metadata self/host/agent_ip)
export MARATHON_FRAMEWORK_NAME=$(metadata self/stack/name)

### dunno how to use this ###
if [ -n "$SECRET" ]; then
    export MARATHON_MESOS_AUTHENTICATION_PRINCIPAL=${MARATHON_MESOS_AUTHENTICATION_PRINCIPAL:-$PRINCIPAL}
    touch /tmp/secret
    chmod 600 /tmp/secret
    echo -n "$SECRET" > /tmp/secret
    export MARATHON_MESOS_AUTHENTICATION_SECRET_FILE=/tmp/secret
fi
### / dunno how to use this ###
