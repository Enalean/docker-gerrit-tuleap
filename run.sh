#!/bin/bash

function set_replication_config {
  gosu ${GERRIT_USER} git config -f "${GERRIT_SITE}/etc/replication.config" "$@"
}

# Customize gerrit.config

# Section gerrit
[ -z "${GERRIT_BASEPATH}" ] || set_gerrit_config gerrit.basePath "${GERRIT_BASEPATH}"
# Section sshd
[ -z "${SSHD_LISTENADDRESS}" ] || set_gerrit_config sshd.listenAddress "${SSHD_LISTENADDRESS}"
# Section cache
[ -z "${CACHE_DIRECTORY}" ] || set_gerrit_config cache.directory "${CACHE_DIRECTORY}"
# Install external plugins
cp -f ${GERRIT_HOME}/replication.jar ${GERRIT_SITE}/plugins/replication.jar

# Customize replication.config
[ -z "${REMOTE_NAME_URL}" ] || set_replication_config remote.${REMOTE_NAME}.url "${REMOTE_NAME_URL}"
[ -z "${REMOTE_NAME_PUSH}" ] || set_replication_config remote.${REMOTE_NAME}.push "${REMOTE_NAME_PUSH}"
[ -z "${REMOTE_NAME_AUTHGROUP}" ] || set_replication_config remote.${REMOTE_NAME}.authGroup "${REMOTE_NAME_AUTHGROUP}"

init=false

if [ ! -d /data/.ssh ]; then
    init=true
    mkdir -p /data/.ssh
    chmod 0700 /data/.ssh
    ssh-keygen -P "" -f /data/.ssh/id_rsa
fi
chown -R ${GERRIT_USER}:${GERRIT_USER} /data/.ssh
ln -s /data/.ssh ${GERRIT_HOME}/.ssh

if [ ! -d /data/git ]; then
    if [ ! -d ${GERRIT_SITE}/git ]; then
        mkdir ${GERRIT_SITE}/git
        chown ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_SITE}/git
    fi

    mv ${GERRIT_SITE}/git /data
    mv ${GERRIT_SITE}/db /data
    mv ${GERRIT_SITE}/logs /data
    mkdir /data/etc
    mv ${GERRIT_SITE}/etc/ssh_host_key /data/etc
else
    rm -rf ${GERRIT_SITE}/git
    rm -rf ${GERRIT_SITE}/db
    rm -rf ${GERRIT_SITE}/logs
    rm -rf ${GERRIT_SITE}/etc/ssh_host_key
fi

ln -s /data/git ${GERRIT_SITE}/git
ln -s /data/db ${GERRIT_SITE}/db
ln -s /data/logs ${GERRIT_SITE}/logs
ln -s /data/etc/ssh_host_key ${GERRIT_SITE}/etc/ssh_host_key

if [ "$init" = "false" ]; then
    echo "Pairing with Tuleap server"
    sleep 5
    su -l ${GERRIT_USER} -c "ssh -oStrictHostKeyChecking=no gitolite@${REMOTE_NAME} info"
fi

# Import LDAP ssl certificate in keystore
if [ -f "/data/server.crt" ]; then
    yes | keytool -importcert -alias ldap-tuleap-local-server -file /data/server.crt -keystore /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/cacerts -storepass changeit
fi
