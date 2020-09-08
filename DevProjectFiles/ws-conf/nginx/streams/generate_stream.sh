#!/bin/bash

set -o pipefail -e

#
SVC="cce-redis"
#
SVC_URL="121.36.34.122:31379"
#
SVC_SVR_PORT="6379"

#
TEMPLATE="stream.svc.conf.tpl"
OUT_PUT_FILE="stream.${SVC}.conf"
#
echo -en "Generating file for ${SVC} using ARGS ${SVC_URL} ${SVC_SVR_PORT}..."
sed "s|%SVC%|$SVC|g;s|%SVC_URL%|$SVC_URL|g;s|%SVC_SVR_PORT%|$SVC_SVR_PORT|g;" $TEMPLATE > ${OUT_PUT_FILE} && \
  echo "done" || \
  echo "failed"
