#!/bin/bash

set -ex

if [ -f /data/etc/gerrit.config ]; then
    cp /data/etc/gerrit.config /home/gerrit/gerrit/etc/gerrit.config
fi

if [ -f /data/etc/etc/replication.config ]; then
    cp /data/etc/etc/replication.config /home/gerrit/gerrit/etc/replication.config
fi

sed -i "s/%SERVER_NAME%/$SERVER_NAME/" /home/gerrit/gerrit/etc/gerrit.config
sed -i "s#%LDAP_SERVER%#$LDAP_SERVER#" /home/gerrit/gerrit/etc/gerrit.config
sed -i "s#%TULEAP_SERVER_NAME%#$TULEAP_SERVER_NAME#" /home/gerrit/gerrit/etc/replication.config

if [ ! -d /data/.ssh ]; then
    mkdir -p /data/.ssh
    chmod 0700 /data/.ssh
    ssh-keygen -P "" -f /data/.ssh/id_rsa
    cat /data/.ssh/id_rsa.pub
fi
chown -R gerrit:gerrit /data/.ssh
ln -s /data/.ssh /home/gerrit/.ssh

if [ ! -d /data/git ]; then
    mv /home/gerrit/gerrit/git /data
    mv /home/gerrit/gerrit/db /data
    mv /home/gerrit/gerrit/logs /data
else
    rm -rf /home/gerrit/gerrit/git
    rm -rf /home/gerrit/gerrit/db
    rm -rf /home/gerrit/gerrit/logs
fi

ln -s /data/git /home/gerrit/gerrit/git
ln -s /data/db /home/gerrit/gerrit/db
ln -s /data/logs /home/gerrit/gerrit/logs

if [ "$1" == "ssh" ]; then
    su -l gerrit -c "ssh -oStrictHostKeyChecking=no gitolite@$TULEAP_SERVER_NAME info"
fi

exec /usr/sbin/service supervisor start
