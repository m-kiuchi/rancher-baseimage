#!/bin/bash
if [ "$1" != "" ]; then
  export ADDUSER=$1
fi
if [ "${SSHUSER}" != "" ]; then
  export ADDUSER=${SSHUSER}
fi
if [ "${ADDUSER}" == "" ]; then
  export ADDUSER=root
fi
echo ${ADDUSER} > /tmp/ADDUSER

__create_user() {
# Create a user to SSH into as.
if [ "$ADDUSER" != "root" ]; then
  useradd $ADDUSER
  usermod -aG wheel $ADDUSER
  echo "${ADDUSER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${ADDUSER}
fi
export SSH_USERPASS=`date|sha1sum|awk '{print $1}'`
echo ${SSH_USERPASS} > /tmp/SSH_USERPASS
echo -e "$SSH_USERPASS\n$SSH_USERPASS" | (passwd --stdin $ADDUSER)
}

# Call all functions
__create_user
