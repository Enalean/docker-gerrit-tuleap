#!/bin/bash

set -ex

if [ -f /data/etc/gerrit.config ]; then
    cp /data/etc/gerrit.config /home/gerrit/gerrit/etc/gerrit.config
fi

if [ -f /data/etc/etc/replication.config ]; then
    cp /data/etc/etc/replication.config /home/gerrit/gerrit/etc/replication.config
fi

sed -i "s#%SERVER_NAME%#$GERRIT_SERVER_NAME#" /home/gerrit/gerrit/etc/gerrit.config
sed -i "s#%LDAP_SERVER%#ldap://ldap#" /home/gerrit/gerrit/etc/gerrit.config
sed -i "s#%TULEAP_SERVER_NAME%#tuleap#" /home/gerrit/gerrit/etc/replication.config

init=false

if [ ! -d /data/.ssh ]; then
    init=true
    mkdir -p /data/.ssh
    chmod 0700 /data/.ssh
    ssh-keygen -P "" -f /data/.ssh/id_rsa
fi
chown -R gerrit:gerrit /data/.ssh
ln -s /data/.ssh /home/gerrit/.ssh

if [ ! -d /data/git ]; then
    mv /home/gerrit/gerrit/git /data
    mv /home/gerrit/gerrit/db /data
    mv /home/gerrit/gerrit/logs /data
    mkdir /data/etc
    mv /home/gerrit/gerrit/etc/ssh_host_key /data/etc
else
    rm -rf /home/gerrit/gerrit/git
    rm -rf /home/gerrit/gerrit/db
    rm -rf /home/gerrit/gerrit/logs
    rm -rf /home/gerrit/gerrit/etc/ssh_host_key
fi

ln -s /data/git /home/gerrit/gerrit/git
ln -s /data/db /home/gerrit/gerrit/db
ln -s /data/logs /home/gerrit/gerrit/logs
ln -s /data/etc/ssh_host_key /home/gerrit/gerrit/etc/ssh_host_key

if [ "$init" = "false" ]; then
    echo "Pairing with Tuleap server"
    sleep 5
    su -l gerrit -c "ssh -oStrictHostKeyChecking=no gitolite@tuleap info"
fi

# Import LDAP ssl certificate in keystore
if [ -f "/data/server.crt" ]; then
    yes | keytool -importcert -alias ldap-tuleap-local-server -file /data/server.crt -keystore /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/cacerts -storepass changeit
fi

exec /usr/sbin/service supervisor start
