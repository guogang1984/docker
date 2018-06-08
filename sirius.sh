#!/bin/sh
# -----------------------------------------------------------------------------
# sirius.sh write by guogang
# -----------------------------------------------------------------------------
# defined DOCKER_PROJ_WEB_NAME DOCKER_PROJ_APP_NAME
# 
#[ -z "$DOCKER_PROJ_WEB_NAME" ] && echo -e "please echo \"export DOCKER_PROJ_WEB_NAME=xxxx\" >> .bash_profile && source .bash_profile " && exit 1

# -----------------------------------------------------------------------------
# docker images pull
# docker pull registry.cn-shenzhen.aliyuncs.com/guogang1984/alpine-tomcat:jdk7tomcat7 > /dev/null
# -----------------------------------------------------------------------------
# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

# Only set SIRIUS_HOME if not already set
# [ -z "$SIRIUS_HOME" ] && SIRIUS_HOME=`cd "$PRGDIR/.." >/dev/null; pwd`
[ -z "$SIRIUS_HOME" ] && SIRIUS_HOME=`cd "$PRGDIR" >/dev/null; pwd`

# Copy SIRIUS_BASE from SIRIUS_HOME if not already set
[ -z "$SIRIUS_BASE" ] && SIRIUS_BASE="$SIRIUS_HOME"
# -----------------------------------------------------------------------------
# Input Params Processor
# -----------------------------------------------------------------------------
if [ "$1" = "nginx" ]; then
  shift
  ~/DevProjectFiles/ws-bin/nginx.sh "$@"
elif [ "$1" = "web" ]; then
  shift
  ~/DevProjectFiles/ws-bin/web.sh "$@"
elif [ "$1" = "db" ]; then
  shift
  ~/DevProjectFiles/ws-bin/db.sh "$@"
elif [ "$1" = "status" ]; then
  docker ps
else
  echo "proj_name : ${DOCKER_PROJ_WEB_NAME} ${DOCKER_PROJ_APP_NAME}"
  echo "Usage: sirius.sh nginx|web ( commands ... )"
  echo "commands:"     
  echo "  nginx start                             Nginx Start in a separate window"
  echo "  nginx stop                              Nginx Stop in a separate window"
  echo "  nginx up [1|2|dev-1|dev-2 ]             Nginx up by reload in a separate window"  
  echo "  nginx -s                                Run nginx -s in a separate window"
  echo "  web                                     Web Status is checked every 5 seconds,  Interrupt Ctrl + C"
  echo "  web pull                                Pull Web binary code From 120.24.*.*"
  echo "  web sync  [1|2|dev-1|dev-2]             Sync Web binary code to ws-root"
  echo "  web start [1|2|dev-1|dev-2]             Web Start, waiting up to 5 seconds for the process to end"
  echo "  web stop  [1|2|dev-1|dev-2]             Web Stop , waiting up to 5 seconds for the process to end"
  echo "  db start mysql                          Db start mysql"  
  echo "  db stop  mysql                          Db stop  mysql"  
  echo "  db back                                 Db back to ws-back"  
  echo "  status                                  Status                         "
  exit 1
fi
