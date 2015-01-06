# gerrit
#
# VERSION               0.0.2

FROM  ubuntu:trusty

MAINTAINER Manuel Vacelet, manuel.vacelet@enalean.com

ENV GERRIT_HOME /home/gerrit
ENV GERRIT_USER gerrit
ENV GERRIT_WAR /home/gerrit/gerrit.war

#RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-7-jre-headless sudo git-core supervisor vim-tiny wget unzip

RUN useradd -m ${GERRIT_USER}

RUN mkdir -p /var/log/supervisor

RUN wget http://gerrit-releases.storage.googleapis.com/gerrit-2.8.6.1.war
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p $GERRIT_HOME/gerrit
RUN mv gerrit-2.8.6.1.war $GERRIT_WAR
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME
#RUN rm -f /etc/apt/apt.conf.d/01proxy

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
