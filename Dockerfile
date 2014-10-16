# gerrit
#
# VERSION               0.0.2

FROM  ubuntu:trusty

MAINTAINER Larry Cai <larry.caiyu@gmail.com>

ENV GERRIT_HOME /home/gerrit
ENV GERRIT_USER gerrit
ENV GERRIT_WAR /home/gerrit/gerrit.war
ENV GERRIT_UPSTREAM gerrit-2.5.6.war

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN useradd -m ${GERRIT_USER}
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-7-jre-headless sudo git-core supervisor vim-tiny
RUN mkdir -p /var/log/supervisor

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget
RUN wget http://gerrit-releases.storage.googleapis.com/${GERRIT_UPSTREAM}
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p $GERRIT_HOME/gerrit
RUN mv ${GERRIT_UPSTREAM} $GERRIT_WAR
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y unzip

USER gerrit
RUN java -jar $GERRIT_WAR init --batch -d $GERRIT_HOME/gerrit

# clobber the gerrit config. set the URL to localhost:8080
ADD gerrit.config $GERRIT_HOME/gerrit/etc/gerrit.config
ADD replication.config $GERRIT_HOME/gerrit/etc/replication.config

RUN unzip -j $GERRIT_WAR WEB-INF/plugins/replication.jar -d $GERRIT_HOME/gerrit/plugins
# Delete plugin TBA

USER root
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

ADD run.sh /run.sh

VOLUME /data

EXPOSE 8080 29418
ENTRYPOINT [ "./run.sh" ]
