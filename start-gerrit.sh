#!/usr/bin/env sh
set -ex

check_gerrit_configuration() {
    if [ ! -f "$GERRIT_SITE/etc/gerrit.config" ]; then
        mkdir -p "$GERRIT_SITE/etc/" && \
        cp "$GERRIT_HOME/gerrit-initial.config" "$GERRIT_SITE/etc/gerrit.config"
    fi
    sed -i "s#%SERVER_NAME%#$GERRIT_SERVER_NAME#" "$GERRIT_SITE/etc/gerrit.config"
    sed -i "s#%LDAP_SERVER%#ldap://ldap#" "$GERRIT_SITE/etc/gerrit.config"
}

check_replication_configuration() {
    if [ ! -f "$GERRIT_SITE/etc/replication.config" ]; then
        mkdir -p "$GERRIT_SITE/etc/" && \
        cp "$GERRIT_HOME/replication-initial.config" "$GERRIT_SITE/etc/replication.config"
    fi
    sed -i "s#%TULEAP_SERVER_NAME%#tuleap#" "$GERRIT_SITE/etc/replication.config"
}

check_configuration_files() {
    check_gerrit_configuration
    check_replication_configuration
}

init_or_upgrade_gerrit() {
    java -jar "$GERRIT_WAR" init --batch --no-auto-start \
      --install-plugin=replication --install-plugin=download-commands\
      --site-path "$GERRIT_SITE"
    java -jar "$GERRIT_WAR" reindex --site-path "$GERRIT_SITE"
}


check_configuration_files
init_or_upgrade_gerrit

exec "$GERRIT_SITE/bin/gerrit.sh" daemon
