#!/bin/sh

[ -z "$DOCKER_PROJ_WEB_NAME" ] && echo -e "please echo \"export DOCKER_PROJ_WEB_NAME=xxxx\" >> .bash_profile && source .bash_profile " && exit 1

# defined DB back
DOCKER_DB_NAME=${DOCKER_PROJ_WEB_NAME}

# -----------------------------------------------------------------------------
DOCKER_FILE_DB_REDIS3=~/DevProjectFiles/ws-docker/docker-compose-db-redis3.yml
DOCKER_FILE_DB_MYSQL=~/DevProjectFiles/ws-docker/docker-compose-db-mysql.yml
DOCKER_FILE_DB_MONGO=~/DevProjectFiles/ws-docker/docker-compose-db-mongo.yml
# -----------------------------------------------------------------------------

CUR_ALL_TIME=`date "+%Y%m%d%H%M%S"`


if [ "$1" = "back" ] ; then
  shift
  if [ "$1" = "mysql" ] ; then
    DOCKER_DB_CID=`docker ps -f name=db-mysql -q`
    DOCKER_DB_BACK_FILE=/DevProjectFiles/ws-back/${DOCKER_DB_NAME}_${CUR_ALL_TIME}.sql
    DOCKER_DB_BACK_OPTS="--user=root --password=root --databases ${DOCKER_DB_NAME}"
    DOCKER_DB_BACK_OPTS="-h localhost -P 3306 --complete-insert --extended-insert=false --add-drop-table --skip-opt --result-file=${DOCKER_DB_BACK_FILE} ${DOCKER_DB_BACK_OPTS}"
    DOCKER_DB_CMD=`echo  -e "mysqldump ${DOCKER_DB_BACK_OPTS}"`
    echo -e "export db '${DOCKER_DB_NAME}' cmd: " && echo -e "mysqldump ${DOCKER_DB_BACK_OPTS}"
    docker exec -it ${DOCKER_DB_CID} ${DOCKER_DB_CMD} > /dev/null
    ls -lh ~/DevProjectFiles/ws-back/${DOCKER_DB_NAME}_${CUR_ALL_TIME}.sql
  fi
elif [ "$1" = "start" ] ; then
  shift

  docker-compose -f $DOCKER_FILE_DB_REDIS3 up -d 

  [ "$1" = "mysql" ] && `docker-compose -f $DOCKER_FILE_DB_MYSQL up -d ` && exit 1
  [ "$1" = "mongo" ] && `docker-compose -f $DOCKER_FILE_DB_MONGO up -d ` && exit 1
elif [ "$1" = "stop" ] ; then   
  shift
  docker-compose -f $DOCKER_FILE_DB_REDIS3 down

  [ "$1" = "mysql" ] && `docker-compose -f $DOCKER_FILE_DB_MYSQL down ` && exit 1
  [ "$1" = "mongo" ] && `docker-compose -f $DOCKER_FILE_DB_MONGO down ` && exit 1
else
  echo "Usage: db-mysql.sh ( commands ... )   ${CUR_ALL_TIME}"
  echo "env: database=${DOCKER_DB_NAME}"   
  echo "commands:"     
  echo "  start mysql                          Db start mysql"  
  echo "  stop  mysql                          Db stop  mysql"  
  echo "  back                                 Db back ${DOCKER_DB_NAME} to ws-back"  
  exit 1
fi
