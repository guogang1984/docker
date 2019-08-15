#!/bin/sh

# network create 
if [ "$1" = "create" ]; then
  shift
  docker network create topflames-net
elif [ "$1" = "ls" ] ; then
  docker network ls
else
  echo "Usage: net.sh ( commands ... )  "
  echo "commands:"     
  echo "  create                 Ccreate a network"
  echo "  ls                     List networks"
  exit 1
fi

