docker run --name=gerrit-data -v /data busybox true

# You need to have 2 running containers, one for ldap, one for tuleap.

docker run -ti --rm=true --name=gerrit --link ldap:ldap --link tuleap:web -e GERRIT_SERVER_NAME=gerrit.gerrit-tuleap.docker --volumes-from=gerrit-data gerrit

On gerrit
- Generate http password
- Set gerrit permissions

On Tuleap:
- execute the setup script
- add gerrit admin entry with http password and ssh key dumped at run
- process system events (dump ssh key)

