#!/bin/bash

./stop-gitlab.sh

docker run \
 --hostname localhost \
 --publish 443:443 \
 --publish 80:80 \
 --publish 2222:22 \
 --name gitlab-sandbox \
 --restart always \
 --volume $(pwd)/config:/etc/gitlab \
 gitlab/gitlab-ce:11.11.8-ce.0

# --volume $(pwd)/logs:/var/log/gitlab \
#--volume $(pwd)/data:/var/opt/gitlab \

