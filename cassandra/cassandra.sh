#!/bin/bash
# define cluster name
if [ "${CLUSTERNAME}" = "" ]; then
  export CLUSTERNAME="mkdefault"
fi

# download and extract cassndra binary
cd
if [ ! -e cassandra ]; then
    tar xzf /apache-cassandra-3.9-bin.tar.gz
    ln -s apache-cassandra-3.9 cassandra
fi

# if this is not seed node, wait for seed node is online
SEEDHOST="seed"
SEEDIP="127.0.0.1"
CASTYPE=$(cat /tmp/CAS_TYPE)
if [ "${CASTYPE}" = "node" ]; then
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
fi
SEEDIP=`host seed|awk '{print $4}'`

# modify cassandra.yaml
cd cassandra/conf
if [ -e cassandra.yaml.org ]; then
    mv cassandra.yaml.org cassandra.yaml
fi
mv cassandra.yaml cassandra.yaml.org
cat cassandra.yaml.org | sed -e 's/^listen_address: localhost/# listen_address: localhost/' > 1
cat 1 | sed -e 's/# listen_interface: eth0/listen_interface: eth0/' > 2
cat 2 | sed -e "s/cluster_name: "\'"Test Cluster"\'"/cluster_name: "\'"${CLUSTERNAME}"\'"/" > 3
cat 3 | sed -e "s/seeds: "\""127.0.0.1"\""/seeds: "\""${SEEDIP}"\""/" > 4
mv 4 cassandra.yaml
rm -f 1 2 3

# start cassndra
cd
export JVM_OPTS="-Dcassandra.consistent.rangemovement=false"
cassandra/bin/cassandra
