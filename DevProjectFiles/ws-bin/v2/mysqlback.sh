#!/bin/bash

CUR_ALL_DATE=`date "+%Y%m%d"`
CUR_ALL_TIME=`date "+%Y%m%d%H%M%S"`

DOCKER_DB_NAME=jyb-service

DB_CMD=`echo  -e "mysqldump ${DOCKER_DB_BACK_OPTS}"`

sudo chmod 755 -R ~/DevProjectFiles/ws-back
sudo mkdir -p ~/DevProjectFiles/ws-back/${DOCKER_DB_NAME}/

RM_DIR=~/DevProjectFiles/ws-back/${DOCKER_DB_NAME}/${DOCKER_DB_NAME}_${CUR_ALL_DATE}\*
sudo rm -rf ${RM_DIR}

DOCKER_DB_CID=`docker ps -f name=db-mysql -q`
DOCKER_DB_BACK_FILE=/DevProjectFiles/ws-back/${DOCKER_DB_NAME}/${DOCKER_DB_NAME}_${CUR_ALL_TIME}.sql
DOCKER_DB_BACK_OPTS="--user=root --password=root --databases ${DOCKER_DB_NAME}"
DOCKER_DB_BACK_OPTS="-h localhost -P 3306 --complete-insert --extended-insert=false --add-drop-table --skip-opt --result-file=${DOCKER_DB_BACK_FILE} ${DOCKER_DB_BACK_OPTS}"
DOCKER_DB_CMD=`echo  -e "mysqldump ${DOCKER_DB_BACK_OPTS}"`
echo -e "export db '${DOCKER_DB_NAME}' cmd: " && echo -e "mysqldump ${DOCKER_DB_BACK_OPTS}"

# docker exec
docker exec -i ${DOCKER_DB_CID} ${DOCKER_DB_CMD} > /dev/null

#
sudo gzip ~/DevProjectFiles/ws-back/${DOCKER_DB_NAME}/${DOCKER_DB_NAME}_${CUR_ALL_TIME}.sql
sudo ls -l ~/DevProjectFiles/ws-back/${DOCKER_DB_NAME}/

UPLOAD_URL="http://jiayoubao.hyszapp.cn/jyb-service/web-public-api/funcJyb/sysBackup/upload"
UPLOAD_FILE="@/home/dev/DevProjectFiles/ws-back/${DOCKER_DB_NAME}/${DOCKER_DB_NAME}_${CUR_ALL_TIME}.sql.gz"
UPLOAD_PARAMS="{\"backupName\":\"backup${CUR_ALL_TIME}\",\"state\":1}"


# upload
echo -e "curl -i ${UPLOAD_URL} -F \"Filedata=${UPLOAD_FILE}\" -F \"params=${UPLOAD_PARAMS}\""
curl -i ${UPLOAD_URL} -F "Filedata=${UPLOAD_FILE}" -F "params=${UPLOAD_PARAMS}"


# 0 0 * * * /home/dev/DevProjectFiles/ws-bin/v2/mysqlback.sh