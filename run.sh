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
    mv ${GERRIT_HOME}/git /data
    mv ${GERRIT_HOME}/db /data
    mv ${GERRIT_HOME}/logs /data
    mkdir /data/etc
    mv ${GERRIT_HOME}/etc/ssh_host_key /data/etc
else
    rm -rf ${GERRIT_HOME}/git
    rm -rf ${GERRIT_HOME}/db
    rm -rf ${GERRIT_HOME}/logs
    rm -rf ${GERRIT_HOME}/etc/ssh_host_key
fi

ln -s /data/git ${GERRIT_HOME}/git
ln -s /data/db ${GERRIT_HOME}/db
ln -s /data/logs ${GERRIT_HOME}/logs
ln -s /data/etc/ssh_host_key ${GERRIT_HOME}/etc/ssh_host_key

if [ "$init" = "false" ]; then
    echo "Pairing with Tuleap server"
    sleep 5
    su -l ${GERRIT_USER} -c "ssh -oStrictHostKeyChecking=no gitolite@${REMOTE_NAME} info"
fi

# Import LDAP ssl certificate in keystore
if [ -f "/data/server.crt" ]; then
    yes | keytool -importcert -alias ldap-tuleap-local-server -file /data/server.crt -keystore /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/cacerts -storepass changeit
fi
