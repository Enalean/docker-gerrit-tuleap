docker run --name=gerrit-data -v /data busybox true

docker run -ti --rm=true --name=gerrit -e LDAP_SERVER=ldap://ldap-write.ldap-dev.dev.docker -e SERVER_NAME=gerrit.gerrit.dev.docker -e TULEAP_SERVER_NAME=red.tuleap-aio-dev.dev.docker --volumes-from=gerrit-data gerrit

On gerrit
- Generate http password
- Set gerrit permissions

On Tuleap:
- execute the setup script
- add gerrit admin entry with http password and ssh key dumped at run
- process system events (dump ssh key)

Restart gerrit instance with "ssh" as option