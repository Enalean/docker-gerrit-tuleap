missing modify:
- gerrit tuleap-documentation
- this README.md

docker run --name=gerrit-data -v /data busybox true

# You need to have 2 running containers, one for ldap, one for tuleap.

This image expects you to have a container named tuleap to run all Tuleap actions
and one container running a LDAP server named ldap.

Run these containers in the same network or if you use a deprecated version of Docker,
create a link between them:
docker run -ti --rm=true --name=gerrit --link ldap:ldap --link tuleap:tuleap -e GERRIT_SERVER_NAME=tuleap_gerrit_1.tuleap-aio-dev.docker --volumes-from=gerrit-data enalean/gerrit-tuleap

On gerrit
- Generate http password
- Set gerrit permissions

On Tuleap:
- execute the setup script
- add gerrit admin entry with http password and ssh key dumped at run
- process system events (dump ssh key)
