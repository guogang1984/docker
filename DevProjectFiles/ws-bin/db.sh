#!/bin/sh



# -----------------------------------------------------------------------------
DOCKER_FILE_DB_REDIS3_1=~/DevProjectFiles/ws-docker/docker-compose-db-redis3-1.yml
DOCKER_FILE_DB_REDIS3_2=~/DevProjectFiles/ws-docker/docker-compose-db-redis3-2.yml
DOCKER_FILE_DB_MYSQL=~/DevProjectFiles/ws-docker/docker-compose-db-mysql.yml
DOCKER_FILE_DB_MONGO=~/DevProjectFiles/ws-docker/docker-compose-db-mongo.yml
# -----------------------------------------------------------------------------

CUR_ALL_TIME=`date "+%Y%m%d%H%M%S"`


if [ "$1" = "back" ] ; then
  shift

  [ -z "$DOCKER_PROJ_WEB_NAME" ] && echo -e "please echo \"export DOCKER_PROJ_WEB_NAME=xxxx\" >> .bash_profile && source .bash_profile " && exit 1

  # defined DB back
  DOCKER_DB_NAME=${DOCKER_PROJ_WEB_NAME}

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

  if [ "$1" = "mysql" ] ; then 
     docker-compose -f ${DOCKER_FILE_DB_MYSQL} up -d 
  elif [ "$1" = "mongo" ] ; then 
     docker-compose -f ${DOCKER_FILE_DB_MONGO} up -d 
  elif [ "$1" = "redis" ] ; then 
     docker-compose -f ${DOCKER_FILE_DB_REDIS3_1} up -d 
     docker-compose -f ${DOCKER_FILE_DB_REDIS3_2} up -d 
  fi
elif [ "$1" = "stop" ] ; then   
  shift
  if [ "$1" = "mysql" ] ; then 
     docker-compose -f ${DOCKER_FILE_DB_MYSQL} down
  elif [ "$1" = "mongo" ] ; then 
     docker-compose -f ${DOCKER_FILE_DB_MONGO} down 
  elif [ "$1" = "redis" ] ; then 
     docker-compose -f ${DOCKER_FILE_DB_REDIS3_1} down
     docker-compose -f ${DOCKER_FILE_DB_REDIS3_2} down
  fi
else
  echo "Usage: db-mysql.sh ( commands ... )   ${CUR_ALL_TIME}"
  echo "env: mysql database=${DOCKER_DB_NAME}"   
  echo "commands:"     
  echo "  start mysql | mongo | redis          Db start mysql | mongo | redis"  
  echo "  stop  mysql | mongo | redis          Db stop  mysql | mongo | redis"  
  echo "  back  mysql                          Db back ${DOCKER_DB_NAME} to ws-back"  
  exit 1
fi
