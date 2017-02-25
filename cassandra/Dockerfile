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

# prepare latest packages
RUN yum -y update; yum clean all
RUN yum -y install openssh-server passwd sudo iproute file bind-utils
RUN yum -y install java-1.8.0-openjdk
RUN yum clean all
RUN curl -O http://ftp.riken.jp/net/apache/cassandra/3.9/apache-cassandra-3.9-bin.tar.gz
RUN chmod 644 apache-cassandra-3.9-bin.tar.gz

# adduser for cassandra
ARG adduser=cassandra
ADD ./start.sh /start.sh
ADD ./adduser.sh /adduser.sh
ADD ./cassandra.sh /cassandra.sh
RUN chmod 755 /start.sh /adduser.sh /cassandra.sh

# prepare ssh
RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

EXPOSE 22 7000 7001 9042 9160
ENTRYPOINT ["/start.sh"]
