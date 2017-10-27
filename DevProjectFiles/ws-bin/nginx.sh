#!/bin/sh

# -----------------------------------------------------------------------------
DOCKER_FILE_NGINX=~/DevProgram/docker/topflames/nginx/docker-compose.yml
# -----------------------------------------------------------------------------
DOCKER_NGINX_CID=`docker ps -f name=web-nginx -q`
# -----------------------------------------------------------------------------
# defined PROJ_CONF_NGINX
[ -z "$PROJ_CONF_NGINX" ] && PROJ_CONF_NGINX=${PROJ_FOLDER}/ws-conf/nginx
# -----------------------------------------------------------------------------

if [ "$1" = "start" ]; then
  docker-compose -f $DOCKER_FILE_NGINX up -d
elif [ "$1" = "stop" ]; then
  docker-compose -f $DOCKER_FILE_NGINX down
elif [ "$1" = "up" ]; then
  shift
  if [ "$1" = "1" ] || [ "$1" = "2" ]; then
    cp ${PROJ_CONF_NGINX}/upstream.conf-$1 ${PROJ_CONF_NGINX}/upstream.conf
  elif [ "$1" = "-host" ] ; then   
    cp ${PROJ_CONF_NGINX}/upstream.conf-tpl  ${PROJ_CONF_NGINX}/upstream.conf
    sed -i "27s/server 127.0.0.1:8081  down;/server $2;/" ~/DevProjectFiles/ws-conf/nginx/upstream.conf
  fi
  docker exec -it ${DOCKER_NGINX_CID} nginx -s reload
  echo -e "\033[32m OK \033[0m step 1. nginx upstream.conf update"
  more ~/DevProjectFiles/ws-conf/nginx/upstream.conf | grep -A 7 cluster_www_tomcat_com
  echo -e "\033[32m OK \033[0m step 2. run nginx -s reload"

elif [ "$1" = "-s" ]; then
  shift
  docker exec -it ${DOCKER_NGINX_CID} nginx -s "$@"
else
  echo "Usage: nginx.sh ( commands ... )  "
  echo "commands:"     
  echo "  start                             Nginx Start in a separate window"
  echo "  stop                              Nginx Stop in a separate window"
  echo "  up [1|2|-host 127.0.0.1:8081 ]    Nginx up by reload in a separate window"  
  echo "  -s [reload]                       Run nginx -s in a separate window"
  exit 1
fi
