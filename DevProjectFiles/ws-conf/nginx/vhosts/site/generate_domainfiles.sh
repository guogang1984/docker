#!/bin/bash

set -o pipefail -e

#
WWW_APP_COM="www.app.com"
#
APP_SERVICE="tx"
#  cluster-tomcat  cluster-dev-tomcat
TARGET_NAME="cluster-tomcat"

#
TEMPLATE="www.app.com.conf.tpl"
#
echo -en "Generating Domainfile for ${WWW_APP_COM} using ARGS ${TARGET_NAME}, ${APP_SERVICE}..."
sed "s|%WWW_APP_COM%|$WWW_APP_COM|g;s|%TARGET_NAME%|$TARGET_NAME|g;s|%APP_SERVICE%|$APP_SERVICE|g" $TEMPLATE > ${WWW_APP_COM}.conf && \
  echo "done" || \
  echo "failed"
