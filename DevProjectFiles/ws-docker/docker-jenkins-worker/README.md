# Building and running a Jenkins master with Docker

docker pull jenkins/jenkins:lts-alpine

Build the image
```bash
docker build -f 8/alpine/Dockerfile -t g127/jenkins-worker:4.3-alpine .

docker push g127/jenkins-worker:4.3-alpine
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
      -e JENKINS_URL=http://ci.topflames.com:80 \
      -e JENKINS_SECRET=02389f9c49f702326fcf04225f117da013ff69c4ccb23924ead2521234d56ca7 \
      -e JENKINS_AGENT_NAME=linux-docker-188 \
      -v $HOME/DevProjectFiles/SupportLibrary/.m2/repository:/home/jenkins/.m2/repository:rw \
      -v $HOME/DevProjectFiles/ws-data/jenkins-worker:/home/jenkins \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --group-add=$(stat -f %g /var/run/docker.sock) \
      --privileged \
      -d g127/jenkins-worker:4.3-alpine
```


Push the image
```bash
docker push g127/jenkins-worker:4.3-alpine
```