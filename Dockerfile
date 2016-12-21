FROM openjdk:8-jre-alpine

ENV GERRIT_HOME /home/gerrit
ENV GERRIT_SITE ${GERRIT_HOME}/site
ENV GERRIT_USER gerrit
ENV GERRIT_GROUP gerrit
ENV GERRIT_WAR ${GERRIT_HOME}/gerrit.war
ENV GERRIT_VERSION 2.12.7
ENV GERRIT_PLUGIN_VERSION stable-2.12

RUN apk add --no-cache openssh openssl git su-exec && \
    addgroup -S "$GERRIT_GROUP" && \
    adduser -S -D -h "$GERRIT_HOME" -G "$GERRIT_GROUP" "$GERRIT_USER"

USER "$GERRIT_USER"

RUN wget "https://gerrit-releases.storage.googleapis.com/gerrit-$GERRIT_VERSION.war" \
      -O "$GERRIT_WAR"

# Let's download plugins from a random CI on the Internet
RUN mkdir -p "$GERRIT_SITE/plugins/" && \
    wget "https://gerrit-ci.gerritforge.com/job/plugin-delete-project-$GERRIT_PLUGIN_VERSION/lastSuccessfulBuild/artifact/buck-out/gen/plugins/delete-project/delete-project.jar" \
      -O "$GERRIT_SITE/plugins/delete-project.jar"

COPY gerrit.config "$GERRIT_HOME/gerrit-initial.config"
COPY replication.config "$GERRIT_HOME/replication-initial.config"

COPY run.sh "$GERRIT_HOME/run.sh"
COPY start-gerrit.sh "$GERRIT_HOME/start-gerrit.sh"

USER root

VOLUME "$GERRIT_HOME"

EXPOSE 8080 29418

ENTRYPOINT "$GERRIT_HOME/run.sh"
