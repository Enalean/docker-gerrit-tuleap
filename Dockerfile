FROM  ubuntu:trusty

MAINTAINER Manuel Vacelet, manuel.vacelet@enalean.com

ENV GERRIT_HOME /home/gerrit
ENV GERRIT_USER gerrit
ENV GERRIT_WAR /home/gerrit/gerrit.war



RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-7-jre-headless sudo git-core supervisor vim-tiny wget unzip && \
    wget http://gerrit-releases.storage.googleapis.com/gerrit-2.8.6.1.war && \
    wget -O /tmp/delete-project.jar https://tuleap.net/file/download.php/101/92/p22_r77/delete-project.jar

RUN useradd -m ${GERRIT_USER} && \
    mkdir -p /var/log/supervisor && \
    mkdir -p $GERRIT_HOME/gerrit && \
    mv gerrit-2.8.6.1.war $GERRIT_WAR && \
    chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

USER gerrit

RUN java -jar $GERRIT_WAR init --batch -d $GERRIT_HOME/gerrit && \
    unzip -j $GERRIT_WAR WEB-INF/plugins/replication.jar -d $GERRIT_HOME/gerrit/plugins && \
    cp /tmp/delete-project.jar $GERRIT_HOME/gerrit/plugins

COPY gerrit.config $GERRIT_HOME/gerrit/etc/gerrit.config
COPY replication.config $GERRIT_HOME/gerrit/etc/replication.config

USER root

RUN rm -rf /tmp/delete-project.jar $GERRIT_WAR
#RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY run.sh /run.sh

VOLUME /data

EXPOSE 8080 29418
ENTRYPOINT [ "./run.sh" ]
