#!/usr/bin/env sh
set -e

fix_permissions() {
    chown -R "$GERRIT_USER":"$GERRIT_GROUP" "$GERRIT_SITE"
}

fix_permissions
"$GERRIT_HOME/start-gerrit.sh"
