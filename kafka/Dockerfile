# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   scollier <scollier@redhat.com>
#
# Modified by Mitsutoshi Kiuchi <m-kiuchi@creationline.com>
#

FROM centos:centos7
MAINTAINER Mitsutoshi Kiuchi <m-kiuchi@creationline.com>

ARG adduser=kafka

RUN yum -y update; yum clean all
RUN yum -y install openssh-server passwd sudo iproute java-1.8.0-openjdk
#RUN rpm -Uvh http://repos.mesosphere.com/el-testing/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm
#RUN yum -y install mesos-0.28.1 mesosphere-zookeeper
RUN yum clean all
#RUN systemctl disable mesos-master mesos-slave zookeeper
RUN systemctl disable sshd
RUN systemctl disable default.target multi-user.target remote-fs.target runlevel2.target runlevel3.target runlevel4.target

RUN cd /opt; curl -O http://ftp.riken.jp/net/apache/kafka/0.10.2.0/kafka_2.12-0.10.2.0.tgz; tar xzf kafka_2.12-0.10.2.0.tgz; ln -s kafka_2.12-0.10.2.0 kafka; rm -f kafka_2.12-0.10.2.0.tgz

ADD ./start.sh /start.sh
ADD ./adduser.sh /adduser.sh
ADD ./mesosconfig.sh /mesosconfig.sh
ADD ./kafkaprepare.sh /kafkaprepare.sh
RUN chmod 755 /start.sh /adduser.sh /mesosconfig.sh /kafkaprepare.sh

RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

#RUN echo $adduser > /loginuser
ENTRYPOINT ["/start.sh"]
