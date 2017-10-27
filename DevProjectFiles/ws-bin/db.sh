#!/bin/sh

[ -z "$DOCKER_PROJ_WEB_NAME" ] && echo -e "please echo \"export DOCKER_PROJ_WEB_NAME=xxxx\" >> .bash_profile && source .bash_profile " && exit 1

# defined DB back
DOCKER_DB_NAME=${DOCKER_PROJ_WEB_NAME}

# -----------------------------------------------------------------------------
DOCKER_FILE_DB=~/DevProjectFiles/ws-docker/docker-compose-db-redis3.yml
# -----------------------------------------------------------------------------

CUR_ALL_TIME=`date "+%Y%m%d%H%M%S"`


DOCKER_DB_CID=`docker ps -f name=db-mysql -q`
DOCKER_DB_BACK_FILE=/DevProjectFiles/ws-back/${DOCKER_DB_NAME}_${CUR_ALL_TIME}.sql
DOCKER_DB_BACK_OPTS="--user=root --password=root --databases ${DOCKER_DB_NAME}"
DOCKER_DB_BACK_OPTS="-h localhost -P 3306 --complete-insert --extended-insert=false --add-drop-table --skip-opt --result-file=${DOCKER_DB_BACK_FILE} ${DOCKER_DB_BACK_OPTS}"
DOCKER_DB_CMD=`echo  -e "mysqldump ${DOCKER_DB_BACK_OPTS}"`

if [ "$1" = "back" ] ; then
  shift
  echo -e "export db '${DOCKER_DB_NAME}' cmd: " && echo -e "mysqldump ${DOCKER_DB_BACK_OPTS}"
  docker exec -it ${DOCKER_DB_CID} ${DOCKER_DB_CMD} > /dev/null
  ls -lh ~/DevProjectFiles/ws-back/${DOCKER_DB_NAME}_${CUR_ALL_TIME}.sql
elif [ "$1" = "start" ] ; then
  shift
  [ "$1" = "mysql" ] && `docker-compose -f $DOCKER_FILE_DB up -d ` && exit 1
elif [ "$1" = "stop" ] ; then   
  shift
  [ "$1" = "mysql" ] && `docker-compose -f $DOCKER_FILE_DB down ` && exit 1
else
  echo "Usage: db-mysql.sh ( commands ... )   ${CUR_ALL_TIME}"
  echo "env: database=${DOCKER_DB_NAME}"   
  echo "commands:"     
  echo "  start mysql                          Db start mysql"  
  echo "  stop  mysql                          Db stop  mysql"  
  echo "  back                                 Db back ${DOCKER_DB_NAME} to ws-back"  
  exit 1
fi
