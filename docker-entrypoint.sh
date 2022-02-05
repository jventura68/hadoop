#!/bin/bash

sudo service ssh start

if [ ! -d "/tmp/hadoop-hduser/dfs/name" ]; then
        $HADOOP_HOME/bin/hdfs namenode -format
fi

hostname="$(hostname -f)"
sed -i "s/localhost/$hostname/" $HADOOP_HOME/etc/hadoop/core-site.xml

$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

tail -f /dev/null $HADOOP_HOME/logs/*

$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/sbin/stop-dfs.sh
