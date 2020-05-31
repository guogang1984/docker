#!/bin/bash

export GITLAB_PERSONAL_ACCESS_TOKEN=$(cat ../gitlab-docker/setup/personal-access-token.txt)
export DOCKER_JENKINS_NAME=jenkins
export M2_DIR=$HOME/DevProjectFiles/SupportLibrary/.m2
export M2_REPO=$HOME/DevProjectFiles/SupportLibrary/.m2/repository
export JENKINS_DATA=$HOME/DevProjectFiles/ws-data/jenkins-casc
export PORT_8080=32081
export PORT_50000=32082
echo --------------------------------------------------------
echo -
echo -  OS: `uname -a`  
echo -  Docker: `docker -v`
echo -
echo -  Using Properties:
echo -
echo -    docker env
echo -      - GITLAB_PERSONAL_ACCESS_TOKEN=$GITLAB_PERSONAL_ACCESS_TOKEN
echo -    docker volume 
echo -      - $M2_REPO:/var/jenkins_home/.m2/repository:rw
echo -      - $JENKINS_DATA:/var/jenkins_home
echo -      - /var/run/docker.sock:/var/run/docker.sock
echo -    docker group-add
echo -      - Linux Using  stat -c %g /var/run/docker.sock 
echo -      - Mac   Using  stat -f %g /var/run/docker.sock 
echo --------------------------------------------------------
echo ""

SYSTEM=`uname -s` # 获取操作系统类型，我本地是linux

# 建立目录
mkdir -p $M2_REPO $JENKINS_DATA

# K8s默认端口范围30000-32767  建议 jenkins 32081 32082

if [ $SYSTEM = "Linux" ] ; then # 如果是linux话输出linux字符串

docker run \
  --name $DOCKER_JENKINS_NAME \
  -u jenkins \
  -p $PORT_8080:8080 \
  -p $PORT_50000:$PORT_50000 \
  -e SLAVE_AGENT_PORT=$PORT_50000 \
  -v $HOME/.ssh:/var/jenkins_home/.ssh:ro \
  -v $M2_DIR:/var/jenkins_home/.m2:rw \
  -v $JENKINS_DATA:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add=$(stat -c %g /var/run/docker.sock) \
  --privileged \
  -d g127/jenkins-casc

elif [ $SYSTEM = "Darwin" ] ; then

docker run \
  --name $DOCKER_JENKINS_NAME \
  -u jenkins \
  -p $PORT_8080:8080 \
  -p $PORT_50000:$PORT_50000 \
  -e SLAVE_AGENT_PORT=$PORT_50000 \
  -e GITLAB_PERSONAL_ACCESS_TOKEN=$GITLAB_PERSONAL_ACCESS_TOKEN \
  -v $HOME/.ssh:/var/jenkins_home/.ssh:ro \
  -v $M2_DIR:/var/jenkins_home/.m2:rw \
  -v $JENKINS_DATA:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add=$(stat -f %g /var/run/docker.sock) \
  --privileged \
  -d g127/jenkins-casc

else
echo "What?"
fi # 判断结束，以fi结尾

docker ps | grep jenkins
