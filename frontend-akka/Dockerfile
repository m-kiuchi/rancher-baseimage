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

ARG adduser=root

RUN yum -y update; yum clean all
RUN yum -y install openssh-server passwd sudo iproute java-1.8.0-openjdk unzip; yum clean all
RUN yum clean all
RUN systemctl disable sshd
RUN systemctl disable default.target multi-user.target remote-fs.target runlevel2.target runlevel3.target runlevel4.target

RUN cd /opt; curl -O https://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12.zip; unzip typesafe-activator-1.3.12.zip; ln -s activator-dist-1.3.12 activator; chmod 755 activator/bin/*

ADD ./start.sh /start.sh
ADD ./adduser.sh /adduser.sh
ADD ./mesosconfig.sh /mesosconfig.sh
ADD ./akkaprepare.sh /akkaprepare.sh
RUN chmod 755 /start.sh /adduser.sh /mesosconfig.sh /akkaprepare.sh

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

RUN chmod 755 /start.sh
#RUN echo $adduser > /loginuser
ENTRYPOINT ["/start.sh"]
