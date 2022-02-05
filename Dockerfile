FROM ubuntu:21.04

ARG HADOOP_VERSION=3.3.1
ARG TAR=hadoop-$HADOOP_VERSION.tar.gz

RUN apt-get update -y && \
    apt-get install vim -y && \
    apt-get install wget -y && \
    apt-get install ssh -y && \
    apt-get install openjdk-8-jdk -y && \
    apt-get install sudo -y
# RUN groupadd hadoop && \
#     useradd -m -s $(which bash) -g hadoop -G sudo hduser && \
#     useradd -m -s $(which bash) -g hadoop -G sudo nifi && \
#     echo hduser:password | chpasswd && \
#     echo nifi:password | chpasswd && \
RUN useradd -m hduser && \
    echo "hduser:pass" | chpasswd && \
    adduser hduser sudo && \
    echo "hduser     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    useradd -m nifi -g hduser && \
    echo "nifi:pass" | chpasswd && \
    adduser nifi sudo && \
    echo "nifi     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /apps && \
    chown -R hduser /apps && \
    cd /usr/bin/ && \
    sudo ln -s python3 python

COPY ssh_config /etc/ssh/ssh_config

WORKDIR /apps

USER hduser
RUN set -eux && \
    wget -q -O "$TAR" https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/${TAR} && \
    tar zxf ${TAR} && \
    rm -fv ${TAR} && \
    ln -sv "hadoop-$HADOOP_VERSION" hadoop && \
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    { rm -rf hadoop/share/doc; : ; } 

ENV HDFS_NAMENODE_USER hduser
ENV HDFS_DATANODE_USER hduser
ENV HDFS_SECONDARYNAMENODE_USER hduser

ENV YARN_RESOURCEMANAGER_USER hduser
ENV YARN_NODEMANAGER_USER hduser

ENV HADOOP_HOME /apps/hadoop
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY core-site.xml $HADOOP_HOME/etc/hadoop/
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/

COPY docker-entrypoint.sh $HADOOP_HOME/etc/hadoop/

ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

ADD examples/ examples/ 

EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22

ENTRYPOINT ["/apps/hadoop/etc/hadoop/docker-entrypoint.sh"]
