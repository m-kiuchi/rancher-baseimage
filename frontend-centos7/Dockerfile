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
RUN yum -y install openssh-server openssh-clients passwd sudo iproute; yum clean all
ADD ./start.sh /start.sh
ADD ./adduser.sh /adduser.sh
RUN chmod 755 /start.sh /adduser.sh

RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

RUN chmod 755 /start.sh
#RUN echo $adduser > /loginuser
ENTRYPOINT ["/start.sh"]
