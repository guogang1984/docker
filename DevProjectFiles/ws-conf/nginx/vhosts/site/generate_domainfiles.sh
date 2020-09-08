#!/bin/bash

# docker run \
#   --name web-nginx \
#   --restart=unless-stopped  \
#   -v ~/DevProjectFiles/ws-conf/nginx/:/usr/local/openresty/nginx/conf/ \
#   -v ~/DevProjectFiles/ws-root/:/DevProjectFiles/ws-root/ \
#   -v ~/tmp/logs/nginx:/usr/local/openresty/nginx/logs \
#   -p 80:80 \
#   -p 8848:8848 \
#   -p 6379:6379
#   --privileged \
#   --net=topflames-net \
#   --link jenkins-casc:ci.topflames.com \
#   --link gitlab:dev.topflames.com \
#   --link sspanel:sazwhhh4.jia54321.com \
#   -d g127/nginx

# docker run \
#   --hostname mysql \
#   --name db-mysql \
#   --restart=unless-stopped  \
#   -e MYSQL_ROOT_PASSWORD='root' \
#   -p 127.0.0.1:3306:3306 \
#   -v ~/DevProjectFiles/ws-conf/alpine/etc/localtime:/etc/localtime:ro \
#   -v ~/DevProjectFiles/ws-conf/mysql:/etc/mysql/conf.d \
#   -v ~/DevProjectFiles/ws-data/mysql:/var/lib/mysql \
#   -v ~/DevProjectFiles/ws-back:/DevProjectFiles/ws-back \
#   --privileged \
#   --net=topflames-net \
#   -d mysql:5.7

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
