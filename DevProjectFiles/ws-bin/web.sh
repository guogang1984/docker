#!/bin/sh

[ -z "$DOCKER_PROJ_WEB_NAME" ] && echo -e "please echo \"export DOCKER_PROJ_WEB_NAME=xxxx\" >> .bash_profile && source .bash_profile " && exit 1

# -----------------------------------------------------------------------------
DOCKER_FILE_WEB1=~/DevProjectFiles/ws-docker/docker-compose-web1.yml
DOCKER_FILE_WEB2=~/DevProjectFiles/ws-docker/docker-compose-web2.yml

DOCKER_FILE_WEB_DEV1=~/DevProjectFiles/ws-docker/docker-compose-web-dev1.yml
DOCKER_FILE_WEB_DEV2=~/DevProjectFiles/ws-docker/docker-compose-web-dev2.yml
# -----------------------------------------------------------------------------
# defined PROJ_FOLDER
[ -z "$PROJ_FOLDER" ] && PROJ_FOLDER=~/DevProjectFiles
# defined PROJ_ROOT 
[ -z "$PROJ_ROOT" ] && PROJ_ROOT=${PROJ_FOLDER}/ws-root
# defined PROJ_RELEASE 
[ -z "$PROJ_RELEASE" ] && PROJ_RELEASE=${PROJ_FOLDER}/ws-release
# defined PROJ_SNAPSHOT
[ -z "$PROJ_SNAPSHOT" ] && PROJ_SNAPSHOT=${PROJ_FOLDER}/ws-snapshot
# defined PROJ_JAVA_WS 
[ -z "$PROJ_JAVA_WS" ] && PROJ_JAVA_WS=${PROJ_FOLDER}/ws-java
# -----------------------------------------------------------------------------
# defined PROJ_CONF
[ -z "$PROJ_CONF" ] && PROJ_CONF=${PROJ_FOLDER}/ws-conf
# defined PROJ_DATA
[ -z "$PROJ_DATA" ] && PROJ_DATA=${PROJ_FOLDER}/ws-data
# defined PROJ_BACK
[ -z "$PROJ_BACK" ] && PROJ_BACK=${PROJ_FOLDER}/ws-back
# -----------------------------------------------------------------------------
# defined PROJ_CONF_RSYNC
# -----------------------------------------------------------------------------
[ -z "$PROJ_CONF_RSYNC" ] && PROJ_CONF_RSYNC=${PROJ_FOLDER}/ws-conf/rsync
[ ! -f "$PROJ_CONF_RSYNC/downloadUser.pas" ]  && `mkdir -p $PROJ_CONF_RSYNC && echo "1234.abcd" > $PROJ_CONF_RSYNC/downloadUser.pas && chmod 700 $PROJ_CONF_RSYNC/downloadUser.pas`
[ ! -f "$PROJ_CONF_RSYNC/exclude.list" ]  && `mkdir -p $PROJ_CONF_RSYNC && echo -e "*/application.properties \n */cygdrive" > $PROJ_CONF_RSYNC/exclude.list && chmod 700 $PROJ_CONF_RSYNC/exclude.list`
# defined REMOTE_FOLDER REMOTE_PWD_FILE EXCLUDE_FILE
REMOTE_RELEASE_FOLDER=rsync://downloadUser@120.24.208.166:873/release
REMOTE_SNAPSHOT_FOLDER=rsync://downloadUser@120.24.208.166:873/snapshot
REMOTE_PWD_FILE=$PROJ_CONF_RSYNC/downloadUser.pas
EXCLUDE_FILE=$PROJ_CONF_RSYNC/exclude.list
# defined RSYNC_OPTS
RSYNC_OPTS="--no-iconv -avzP --progress --delete --exclude-from=${EXCLUDE_FILE}"
RSYNC_REMOTE_OPTS="--no-iconv -avzP --progress --delete --password-file=${REMOTE_PWD_FILE} --exclude-from=${EXCLUDE_FILE}"
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# defined tomcat xml

[ ! -f "${PROJ_FOLDER}/ws-conf/tomcat7/localhost18081/${DOCKER_PROJ_WEB_NAME}.xml" ] && \
  `mkdir -p ${PROJ_FOLDER}/ws-conf/tomcat7/localhost18081/ && echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/${DOCKER_PROJ_WEB_NAME}-1\" />" > ${PROJ_FOLDER}/ws-conf/tomcat7/localhost18081/${DOCKER_PROJ_WEB_NAME}.xml `

[ ! -f "${PROJ_FOLDER}/ws-conf/tomcat7/localhost18082/${DOCKER_PROJ_WEB_NAME}.xml" ] && \
  `mkdir -p ${PROJ_FOLDER}/ws-conf/tomcat7/localhost18082/ && echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/${DOCKER_PROJ_WEB_NAME}-2\" />" > ${PROJ_FOLDER}/ws-conf/tomcat7/localhost18082/${DOCKER_PROJ_WEB_NAME}.xml `

[ ! -d "~/tmp/logs/web1/tmp" ] && mkdir -p ~/tmp/logs/web1/tmp
[ ! -d "~/tmp/logs/web2/tmp" ] && mkdir -p ~/tmp/logs/web2/tmp


[ ! -f "${PROJ_FOLDER}/ws-conf/tomcat7/localhost28081/${DOCKER_PROJ_WEB_NAME}-dev.xml" ] && \
  `mkdir -p ${PROJ_FOLDER}/ws-conf/tomcat7/localhost28081/ && echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/${DOCKER_PROJ_WEB_NAME}-dev-1\" />" > ${PROJ_FOLDER}/ws-conf/tomcat7/localhost28081/${DOCKER_PROJ_WEB_NAME}-dev.xml `

[ ! -f "${PROJ_FOLDER}/ws-conf/tomcat7/localhost28082/${DOCKER_PROJ_WEB_NAME}-dev.xml" ] && \
  `mkdir -p ${PROJ_FOLDER}/ws-conf/tomcat7/localhost28082/ && echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/${DOCKER_PROJ_WEB_NAME}-dev-2\" />" > ${PROJ_FOLDER}/ws-conf/tomcat7/localhost28082/${DOCKER_PROJ_WEB_NAME}-dev.xml `

[ ! -d "~/tmp/logs/web-dev1/tmp" ] && mkdir -p ~/tmp/logs/web-dev1/tmp
[ ! -d "~/tmp/logs/web-dev2/tmp" ] && mkdir -p ~/tmp/logs/web-dev2/tmp


# -----------------------------------------------------------------------------

if [ "$1" = "pull" ] ; then
  # pull class
  if [ ! -z "$2" ]; then
    SOURCE_FOLDER=${REMOTE_RELEASE_FOLDER}
    DIST_FOLDER=${PROJ_RELEASE}
    rsync ${RSYNC_REMOTE_OPTS} ${SOURCE_FOLDER}/$2 ${DIST_FOLDER}
    echo "  " && echo "rsync ${SOURCE_FOLDER}/$2 ${DIST_FOLDER} success!"
  else
    SOURCE_FOLDER=${REMOTE_RELEASE_FOLDER}
    DIST_FOLDER=${PROJ_RELEASE}
    rsync ${RSYNC_REMOTE_OPTS} ${SOURCE_FOLDER}/${DOCKER_PROJ_WEB_NAME} ${DIST_FOLDER}
    echo "  " && echo "rsync ${SOURCE_FOLDER}/${DOCKER_PROJ_WEB_NAME} ${DIST_FOLDER} success!"

    SOURCE_FOLDER=${REMOTE_RELEASE_FOLDER}
    DIST_FOLDER=${PROJ_RELEASE}
    rsync ${RSYNC_REMOTE_OPTS} ${SOURCE_FOLDER}/${DOCKER_PROJ_WEB_NAME}-dev ${DIST_FOLDER}
    echo "  " && echo "rsync ${SOURCE_FOLDER}/${DOCKER_PROJ_WEB_NAME}-dev ${DIST_FOLDER} success!"
  fi

elif [ "$1" = "sync" ]; then
  shift
  if [ "$1" = "1" ] || [ "$1" = "2" ]; then
    if [ ! -z "$2" ]; then
      SOURCE_FOLDER=${PROJ_RELEASE}/${DOCKER_PROJ_WEB_NAME}/target/$2/
      DIST_FOLDER=${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/
      rsync ${RSYNC_OPTS} ${SOURCE_FOLDER} ${DIST_FOLDER}
      cp ${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/WEB-INF/classes/application.docker.properties ${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/WEB-INF/classes/application.properties            
    else
      SOURCE_FOLDER=${PROJ_RELEASE}/${DOCKER_PROJ_WEB_NAME}/target/${DOCKER_PROJ_WEB_NAME}-1.0-SNAPSHOT/
      DIST_FOLDER=${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/
      rsync ${RSYNC_OPTS} ${SOURCE_FOLDER} ${DIST_FOLDER}
      cp ${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/WEB-INF/classes/application.docker.properties ${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/WEB-INF/classes/application.properties      
    fi 
    echo "  "
    echo "rsync ${SOURCE_FOLDER} ${DIST_FOLDER} success!"
  elif [ "$1" = "dev-1" ] || [ "$1" = "dev-2" ];  then
    if [ ! -z "$2" ]; then
      SOURCE_FOLDER=${PROJ_RELEASE}/${DOCKER_PROJ_WEB_NAME}-dev/target/$2/
      DIST_FOLDER=${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/
      rsync ${RSYNC_OPTS} ${SOURCE_FOLDER} ${DIST_FOLDER}
      cp ${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/WEB-INF/classes/application.dev.docker.properties ${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/WEB-INF/classes/application.properties
    else
      SOURCE_FOLDER=${PROJ_RELEASE}/${DOCKER_PROJ_WEB_NAME}-dev/target/${DOCKER_PROJ_WEB_NAME}-1.0-SNAPSHOT/
      DIST_FOLDER=${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/
      rsync ${RSYNC_OPTS} ${SOURCE_FOLDER} ${DIST_FOLDER}
      cp ${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/WEB-INF/classes/application.dev.docker.properties ${PROJ_ROOT}/${DOCKER_PROJ_WEB_NAME}-$1/WEB-INF/classes/application.properties
    fi 
    echo "  "
    echo "rsync ${SOURCE_FOLDER} ${DIST_FOLDER} success!"
  else
    echo "sync [1|2|dev-1|dev-2] ?"
  fi
elif [ "$1" = "start" ]; then
  shift
  [ "$1" = "1" ]     && `docker-compose -f $DOCKER_FILE_WEB1 up -d ` && exit 1
  [ "$1" = "2" ]     && `docker-compose -f $DOCKER_FILE_WEB2 up -d` && exit 1
  [ "$1" = "dev-1" ] && `docker-compose -f $DOCKER_FILE_WEB_DEV1 up -d ` && exit 1
  [ "$1" = "dev-2" ] && `docker-compose -f $DOCKER_FILE_WEB_DEV2 up -d` && exit 1
elif [ "$1" = "stop" ]; then
  shift
  [ "$1" = "1" ]     && `docker-compose -f $DOCKER_FILE_WEB1 down ` && exit 1
  [ "$1" = "2" ]     && `docker-compose -f $DOCKER_FILE_WEB2 down ` && exit 1
  [ "$1" = "dev-1" ] && `docker-compose -f $DOCKER_FILE_WEB_DEV1 down ` && exit 1
  [ "$1" = "dev-2" ] && `docker-compose -f $DOCKER_FILE_WEB_DEV2 down ` && exit 1
elif [ "$1" = "status" ]; then
  shift
  echo -e "the web status is checked every 5 seconds, 200 is OK Interrupt Ctrl + C "
  while true
  do
    status18081=`curl -I -m 10 -o /dev/null -s -w %{http_code}  127.0.0.1:18081/${DOCKER_PROJ_WEB_NAME}/login`
    status18082=`curl -I -m 10 -o /dev/null -s -w %{http_code}  127.0.0.1:18082/${DOCKER_PROJ_WEB_NAME}/login`
    status18081dev=`curl -I -m 10 -o /dev/null -s -w %{http_code}  127.0.0.1:28081/${DOCKER_PROJ_WEB_NAME}-dev/login`
    status18082dev=`curl -I -m 10 -o /dev/null -s -w %{http_code}  127.0.0.1:28082/${DOCKER_PROJ_WEB_NAME}-dev/login`
    echo -e "web1:${DOCKER_PROJ_WEB_NAME}/login CODE:\033[32m ${status18081} \033[0m   |   \c"
    echo -e "web2:${DOCKER_PROJ_WEB_NAME}/login CODE:\033[32m ${status18082} \033[0m   ||   \c"
    echo -e "web1 dev:${DOCKER_PROJ_WEB_NAME}/login CODE:\033[32m ${status18081dev} \033[0m   |   \c"
    echo -e "web2 dev:${DOCKER_PROJ_WEB_NAME}/login CODE:\033[32m ${status18082dev} \033[0m "
    status18081=""
    status18082=""
    status18081dev=""
    status18082dev=""
  sleep 5
  done
else
  echo "Usage: web.sh ( commands ... )  "
  echo "commands:"     
  echo "  status                              Web Status is checked every 5 seconds,  Interrupt Ctrl + C"
  echo "  pull                                Pull Web ${DOCKER_PROJ_WEB_NAME} binary code From 120.24.*.*"
  echo "  sync  [1|2|dev-1|dev-2]             Sync Web binary code to ws-root"
  echo "  start [1|2|dev-1|dev-2]             Web Start, waiting up to 5 seconds for the process to end"
  echo "  stop  [1|2|dev-1|dev-2]             Web Stop , waiting up to 5 seconds for the process to end"
  exit 1
fi
