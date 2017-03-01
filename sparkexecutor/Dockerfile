# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   scollier <scollier@redhat.com>
#
# Modified by Mitsutoshi Kiuchi <m-kiuchi@creationline.com>
#
# Based on:
#   - Mesos 0.28.1(from: http://repos.mesosphere.com/el-testing/7)
#   - Spark 2.0.2

FROM centos:centos7
MAINTAINER Mitsutoshi Kiuchi <m-kiuchi@creationline.com>

ARG adduser=spark

RUN yum -y update; yum clean all
RUN yum -y install openssh-server passwd sudo iproute
RUN rpm -Uvh http://repos.mesosphere.com/el-testing/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm
RUN yum -y install mesos-0.28.1 mesosphere-zookeeper
RUN yum clean all
RUN systemctl disable mesos-master mesos-slave zookeeper sshd
RUN systemctl disable default.target multi-user.target remote-fs.target runlevel2.target runlevel3.target runlevel4.target

RUN cd opt; curl -O http://ftp.riken.jp/net/apache/spark/spark-2.0.2/spark-2.0.2-bin-hadoop2.7.tgz; tar xzf spark-2.0.2-bin-hadoop2.7.tgz; ln -s spark-2.0.2-bin-hadoop2.7 spark; rm -f spark-2.0.2-bin-hadoop2.7.tgz

ADD ./start.sh /start.sh
ADD ./adduser.sh /adduser.sh
ADD ./mesosconfig.sh /mesosconfig.sh
RUN chmod 755 /start.sh /adduser.sh /mesosconfig.sh

RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

#RUN echo $adduser > /loginuser
ENTRYPOINT ["/start.sh"]
