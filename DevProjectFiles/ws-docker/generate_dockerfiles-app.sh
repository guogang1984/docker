#!/bin/bash
set -o pipefail -e

# TIME
STAMP=`date +%Y%m%d%H%M%S`

# INPUT TPL, OUT_FILE
TPL=${GG_APP_TPL:=docker-compose-app.yml.tpl} && \
  OUT_FILE=${GG_APP_FILE:=docker-compose-app.yml} && echo -e " TPL=$TPL, OUT_FILE=$OUT_FILE"

# INPUT APP_NAME, APP_JAR_NAME, APP_PORTS, APP_NETWORKS
APP_CONTAINER_NAME=${GG_APP_CONTAINER_NAME:="dac-cuiyu-spray"} && \
  APP_PORTS=${GG_APP_PORTS:="35555:18888"} && \
  APP_NETWORKS=${GG_APP_NETWORKS:="app-net"} && \
    APP_JAR_NAME=${GG_APP_JAR_NAME:="cuiyu-spray-dac-0.0.1-SNAPSHOT.jar"}

# Backup Exist $OUT_FILE
[ -f "$OUT_FILE" ] && `mv $OUT_FILE ${OUT_FILE}.bak` && \
  echo -e "\033[32m Done   \033[0m Backup $DAC_FILE success! "

# Generating $OUT_FILE
sed "s|%STAMP%|$STAMP|g;s|%TPL%|$TPL|g;s|%OUT_FILE%|$OUT_FILE|g;s|%APP_CONTAINER_NAME%|$APP_CONTAINER_NAME|g;s|%APP_PORTS%|$APP_PORTS|g;s|%APP_NETWORKS%|$APP_NETWORKS|g;s|%APP_JAR_NAME%|$APP_JAR_NAME|g;" $TPL > ${OUT_FILE} && \
  echo -e "\033[32m Done   \033[0m Generating success! " || \
  echo -e "\033[31m Failed \031[0m Generating failed! "
