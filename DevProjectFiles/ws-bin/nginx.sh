#!/bin/sh

# -----------------------------------------------------------------------------
DOCKER_FILE_NGINX=~/DevProjectFiles/ws-docker/docker-compose-nginx.yml
# -----------------------------------------------------------------------------
DOCKER_NGINX_CID=`docker ps -f name=web-nginx -q`
# -----------------------------------------------------------------------------
# defined PROJ_FOLDER
[ -z "$PROJ_FOLDER" ] && PROJ_FOLDER=~/DevProjectFiles
# defined PROJ_CONF_NGINX
[ -z "$PROJ_CONF_NGINX" ] && PROJ_CONF_NGINX=${PROJ_FOLDER}/ws-conf/nginx
# -----------------------------------------------------------------------------

if [ "$1" = "start" ]; then

  [ ! -f "${PROJ_CONF_NGINX}/geoip/GeoIP.dat" ] && \
     `wget -N -O ${PROJ_CONF_NGINX}/geoip/GeoIP.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz && gunzip ${PROJ_CONF_NGINX}/geoip/GeoIP.dat.gz`
  [ ! -f "${PROJ_CONF_NGINX}/geoip/GeoLiteCity.dat" ] && \
     `wget -N -O ${PROJ_CONF_NGINX}/geoip/GeoLiteCity.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && gunzip ${PROJ_CONF_NGINX}/geoip/GeoLiteCity.dat.gz`

  docker-compose -f $DOCKER_FILE_NGINX up -d
elif [ "$1" = "stop" ]; then
  docker-compose -f $DOCKER_FILE_NGINX down
elif [ "$1" = "up" ]; then
  shift
  if   [ "$1" = "1" ] ; then
     sed -i "s/server 127.0.0.1:18081 down;/server 127.0.0.1:18081     ;/g" ~/DevProjectFiles/ws-conf/nginx/upstream.conf 
     sed -i "s/server 127.0.0.1:18082 \+;/server 127.0.0.1:18082 down;/g" ~/DevProjectFiles/ws-conf/nginx/upstream.conf
  elif [ "$1" = "2" ] ; then   
     sed -i "s/server 127.0.0.1:18081 \+;/server 127.0.0.1:18081 down;/g" ~/DevProjectFiles/ws-conf/nginx/upstream.conf
     sed -i "s/server 127.0.0.1:18082 down;/server 127.0.0.1:18082     ;/g" ~/DevProjectFiles/ws-conf/nginx/upstream.conf 
  elif [ "$1" = "dev-1" ] ; then  
     sed -i "s/server 127.0.0.1:28081 down;/server 127.0.0.1:28081     ;/g" ~/DevProjectFiles/ws-conf/nginx/upstream.conf 
     sed -i "s/server 127.0.0.1:28082 \+;/server 127.0.0.1:28082 down;/g" ~/DevProjectFiles/ws-conf/nginx/upstream.conf
  elif [ "$1" = "dev-2" ] ; then 
     sed -i "s/server 127.0.0.1:28081 \+;/server 127.0.0.1:28081 down;/g" ~/DevProjectFiles/ws-conf/nginx/upstream.conf
     sed -i "s/server 127.0.0.1:28082 down;/server 127.0.0.1:28082     ;/g" ~/DevProjectFiles/ws-conf/nginx/upstream.conf 
  elif [ "$1" = "-host" ] ; then   
    cp ${PROJ_CONF_NGINX}/upstream.conf-tpl  ${PROJ_CONF_NGINX}/upstream.conf
    sed -i "27s/server 127.0.0.1:8081  down;/server $2;/" ~/DevProjectFiles/ws-conf/nginx/upstream.conf
  fi
  docker exec -it ${DOCKER_NGINX_CID} nginx -s reload
  echo -e "\033[32m OK \033[0m step 1. nginx upstream.conf update"
  more ~/DevProjectFiles/ws-conf/nginx/upstream.conf | grep -A 7 cluster_www_tomcat_com
  more ~/DevProjectFiles/ws-conf/nginx/upstream.conf | grep -A 7 cluster_dev_tomcat_com
  echo -e "\033[32m OK \033[0m step 2. run nginx -s reload"

elif [ "$1" = "-s" ]; then
  shift
  docker exec -it ${DOCKER_NGINX_CID} nginx -s "$@"

  echo -e "\033[32m OK \033[0m show nginx upstream.conf "
  more ~/DevProjectFiles/ws-conf/nginx/upstream.conf | grep -A 7 cluster_www_tomcat_com
  more ~/DevProjectFiles/ws-conf/nginx/upstream.conf | grep -A 7 cluster_dev_tomcat_com

elif [ "$1" = "stream" ] ; then   
  shift
  if [ "$1" = "config" ]; then
    shift
    if [ ! -z "$1" ] && [ -f "${PROJ_CONF_NGINX}/stream/mongo.conf.tpl" ]; then
      sed "s|%HOSTIP%|$1|g;" ${PROJ_CONF_NGINX}/stream/mongo.conf.tpl > ${PROJ_CONF_NGINX}/stream/mongo.conf
    fi
    if [ ! -z "$1" ] && [ -f "${PROJ_CONF_NGINX}/stream/mysql.conf.tpl" ]; then
      sed "s|%HOSTIP%|$1|g;" ${PROJ_CONF_NGINX}/stream/mysql.conf.tpl > ${PROJ_CONF_NGINX}/stream/mysql.conf
    fi
    if [ ! -z "$1" ] && [ -f "${PROJ_CONF_NGINX}/stream/redis3.conf.tpl" ]; then
      sed "s|%HOSTIP%|$1|g;" ${PROJ_CONF_NGINX}/stream/redis3.conf.tpl > ${PROJ_CONF_NGINX}/stream/redis3.conf
    fi 
  fi 
else
  echo "Usage: nginx.sh ( commands ... )  "
  echo "commands:"     
  echo "  start                             Nginx Start in a separate window"
  echo "  stop                              Nginx Stop in a separate window"
  echo "  stream config                     Nginx Stream in a separate window" 
  echo "  up [1|2|dev-1|dev-2 ]             Nginx up by reload in a separate window"  
  echo "  -s [reload]                       Run nginx -s in a separate window"
  exit 1
fi
