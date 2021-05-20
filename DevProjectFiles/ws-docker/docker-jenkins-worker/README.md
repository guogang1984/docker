# Building and running a Jenkins master with Docker

docker pull jenkins/jenkins:lts-alpine

Build the image  node14
```bash
docker build -f 8/alpine/Dockerfile -t g127/jenkins-worker:devops .

docker push g127/jenkins-worker:devops


docker tag g127/jenkins-worker:devops swr.cn-north-4.myhuaweicloud.com/chinasoft_csi_paas/devops-jenkins-worker:1128

docker push swr.cn-north-4.myhuaweicloud.com/chinasoft_csi_paas/devops-jenkins-worker:1128

docker pull swr.cn-north-4.myhuaweicloud.com/chinasoft_csi_paas/devops-jenkins-worker:1128
```

Build the image2  node10
```bash
docker build -f 8/alpine/Dockerfile.node10 -t g127/jenkins-worker:devops-node10 .

docker push g127/jenkins-worker:devops-node10


docker tag g127/jenkins-worker:devops-node10 swr.cn-north-4.myhuaweicloud.com/chinasoft_csi_paas/devops-jenkins-worker:1128-node10

docker push swr.cn-north-4.myhuaweicloud.com/chinasoft_csi_paas/devops-jenkins-worker:1128-node10

docker pull swr.cn-north-4.myhuaweicloud.com/chinasoft_csi_paas/devops-jenkins-worker:1128-node10
```

Test the image
```bash
# linux
docker run \
      --user jenkins \
      --name jenkins-worker \
      --restart=unless-stopped  \
      --init \
      -e JENKINS_URL=http://ci.topflames.com:80 \
      -e JENKINS_SECRET=02389f9c49f702326fcf04225f117da013ff69c4ccb23924ead2521234d56ca7 \
      -e JENKINS_AGENT_NAME=linux-docker-188 \
      -v $HOME/DevProjectFiles/SupportLibrary/.m2/repository:/home/jenkins/.m2/repository:rw \
      -v $HOME/DevProjectFiles/ws-data/jenkins-worker:/home/jenkins \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --group-add=$(stat -c %g /var/run/docker.sock) \
      --privileged \
      g127/jenkins-worker:4.3-alpine

docker run \
      --user jenkins \
      --name jenkins-worker \
      --restart=unless-stopped  \
      --init \
      -e JENKINS_URL=http://ci.tf360.com:80 \
      -e JENKINS_SECRET=3b1bda922c06c10ceaa258f2b177391d2244ae8d1b0ff40c3f93ecffd5e7f93e \
      -e JENKINS_AGENT_NAME=win-185 \
      -v D:/DevProjectFiles/SupportLibrary/.m2/repository:/home/jenkins/.m2/repository:rw \
      -v D://DevProjectFiles/ws-data/jenkins-worker:/home/jenkins \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --group-add=$(stat -f %g /var/run/docker.sock) \
      --privileged \
      -d g127/jenkins-worker:4.3-alpine


docker run \
      --user jenkins \
      --name jenkins-worker \
      --restart=unless-stopped  \
      --init \
      -e JENKINS_URL=http://ci.tf360.com:80 \
      -e JENKINS_SECRET=3b1bda922c06c10ceaa258f2b177391d2244ae8d1b0ff40c3f93ecffd5e7f93e \
      -e JENKINS_AGENT_NAME=win-185 \
      -v D:/DevProjectFiles/SupportLibrary/.m2/repository:/home/jenkins/.m2/repository:rw \
      -v D://DevProjectFiles/ws-data/jenkins-worker:/home/jenkins \
      --privileged \
      -d g127/jenkins-worker:alpine 
```


Push the image
```bash
docker push g127/jenkins-worker:4.3-alpine
```