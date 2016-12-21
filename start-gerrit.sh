#!/usr/bin/env sh
set -ex

check_gerrit_configuration() {
    if [ ! -f "$GERRIT_SITE/etc/gerrit.config" ]; then
        mkdir -p "$GERRIT_SITE/etc/" && \
        cp "$GERRIT_LIB/gerrit-initial.config" "$GERRIT_SITE/etc/gerrit.config"
    fi
    sed -i "s#%SERVER_NAME%#$GERRIT_SERVER_NAME#" "$GERRIT_SITE/etc/gerrit.config"
    sed -i "s#%LDAP_SERVER%#ldap://ldap#" "$GERRIT_SITE/etc/gerrit.config"
}

check_replication_configuration() {
    if [ ! -f "$GERRIT_SITE/etc/replication.config" ]; then
        mkdir -p "$GERRIT_SITE/etc/" && \
        cp "$GERRIT_LIB/replication-initial.config" "$GERRIT_SITE/etc/replication.config"
    fi
    sed -i "s#%TULEAP_SERVER_NAME%#tuleap#" "$GERRIT_SITE/etc/replication.config"
}

check_configuration_files() {
    check_gerrit_configuration
    check_replication_configuration
}

create_gerrit_user_ssh_key() {
    mkdir -p /home/gerrit/.ssh/
    chmod 0700  /home/gerrit/.ssh/
    ssh-keygen -P "" -f /home/gerrit/.ssh/id_rsa
}

pair_with_tuleap_server() {
    echo "Pairing with Tuleap server"
    sleep 5
    ssh -oStrictHostKeyChecking=no gitolite@tuleap info
}

manage_ssh_key() {
    if [ ! -d /home/gerrit/.ssh/ ]; then
        create_gerrit_user_ssh_key
    else
        pair_with_tuleap_server
    fi
}

init_or_upgrade_gerrit() {
    java -jar "$GERRIT_WAR" init --batch --no-auto-start \
      --install-plugin=replication --install-plugin=download-commands\
      --site-path "$GERRIT_SITE"
    java -jar "$GERRIT_WAR" reindex --site-path "$GERRIT_SITE"
}

deploy_plugins() {
    cp -f "$GERRIT_LIB"/plugins/* "$GERRIT_SITE/plugins"
}


check_configuration_files
manage_ssh_key
init_or_upgrade_gerrit
deploy_plugins

exec "$GERRIT_SITE/bin/gerrit.sh" daemon
