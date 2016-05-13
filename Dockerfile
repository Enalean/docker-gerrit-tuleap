FROM openfrontier/gerrit:latest

# Have command ssh-keygen
RUN apt-get update && apt-get install -y openssh-client

# Download Plugins
# replication
RUN curl \
    -L ${GERRITFORGE_URL}/job/plugin-replication-${PLUGIN_VERSION}/${GERRITFORGE_ARTIFACT_DIR}/replication/replication.jar \
    -o ${GERRIT_HOME}/replication.jar

# Customize gerrit.config
COPY ./run.sh /docker-entrypoint-init.d/run.sh
RUN chmod 755 /docker-entrypoint-init.d/run.sh

EXPOSE 8080 29418
