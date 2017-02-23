#!/bin/bash
ADDUSER=$1
if [ "${SSHUSER}" != "" ]; then
  ADDUSER=${SSHUSER}
fi
if [ "${ADDUSER}" == "" ]; then
  ADDUSER=root
fi
echo $ADDUSER

__create_user() {
# Create a user to SSH into as.
if [ "$ADDUSER" != "root" ]; then
  useradd $ADDUSER
  usermod -aG wheel $ADDUSER
fi
SSH_USERPASS=`date|sha1sum|awk '{print $1}'`
echo -e "$SSH_USERPASS\n$SSH_USERPASS" | (passwd --stdin $ADDUSER)
echo "--------------------"
echo " SSH PASSWORD - please change immediately"
echo " username: ${ADDUSER} , password: ${SSH_USERPASS}"
echo "--------------------"
}

# Call all functions
__create_user
/usr/sbin/sshd -D
