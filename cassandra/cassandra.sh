#!/bin/bash
# define cluster name
if [ "${CLUSTERNAME}" = "" ]; then
  export CLUSTERNAME="mkdefault"
fi

# if this is not seed node, wait for seed node is online
SEEDHOST=$(cat /tmp/SEED_IP)
SEEDIP=$(cat /tmp/SEED_IP)
CASTYPE=$(cat /tmp/CAS_TYPE)
if [ "${CASTYPE}" = "node" ]; then
    echo "I am data node"
    while :; do
        ping -c 1 ${SEEDHOST}
        if [ "$?" = "0" ]; then
            echo "seed host discovered"
            break
        else
            echo "waiting for seed host"
            sleep 3
        fi
    done
else
    echo "I am seed node"
fi
#SEEDIP=`host seed|awk '{print $4}'`

# modify cassandra.yaml
cd /opt/cassandra/conf
if [ -e cassandra.yaml.org ]; then
    sudo mv cassandra.yaml.org cassandra.yaml
fi
sudo mv cassandra.yaml cassandra.yaml.org
cat cassandra.yaml.org | sed -e 's/^listen_address: localhost/# listen_address: localhost/' > /tmp/1
cat /tmp/1 | sed -e 's/# listen_interface: eth0/listen_interface: eth0/' > /tmp/2
cat /tmp/2 | sed -e "s/cluster_name: "\'"Test Cluster"\'"/cluster_name: "\'"${CLUSTERNAME}"\'"/" > /tmp/3
cat /tmp/3 | sed -e "s/seeds: "\""127.0.0.1"\""/seeds: "\""${SEEDIP}"\""/" > /tmp/4
sudo mv /tmp/4 /opt/cassandra/conf/cassandra.yaml
cd /tmp; rm -f 1 2 3

sudo mkdir -p /opt/cassandra/data
sudo chmod 777 /opt/cassandra/data

# start cassndra
cd
export JVM_OPTS="-Dcassandra.consistent.rangemovement=false"
/opt/cassandra/bin/cassandra
