#!/bin/sh

# . "$DEV_PROJECT_FILES_HOME"/ws-bin/v2/setconfig.sh

# Make sure prerequisite environment variables are set
if [ -z "$DEV_PROJECT_FILES_HOME" ]; then
  DEV_PROJECT_FILES_HOME="/home/dev/DevProjectFiles"
fi

# -----------------------------------------------------------------------------
# db docker file
# -----------------------------------------------------------------------------
DOCKER_FILE_DB_REDIS3_1="$DEV_PROJECT_FILES_HOME"/ws-docker/docker-compose-db-redis3-1.yml
DOCKER_FILE_DB_REDIS3_2="$DEV_PROJECT_FILES_HOME"/ws-docker/docker-compose-db-redis3-2.yml
DOCKER_FILE_DB_MYSQL="$DEV_PROJECT_FILES_HOME"/ws-docker/docker-compose-db-mysql.yml
DOCKER_FILE_DB_MONGO="$DEV_PROJECT_FILES_HOME"/ws-docker/docker-compose-db-mongo.yml
# -----------------------------------------------------------------------------


