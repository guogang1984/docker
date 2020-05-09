# Building and running a Jenkins master with Docker

docker pull jenkins/jenkins:lts-alpine

Build the image
```bash
docker build -t g127/jenkins-casc .
```

You can decide which Jenkins version to used by passing the `jenkins_tag` docker build argument like in the following
```bash
docker build --build-arg jenkins_tag=lts-alpine -t g127/jenkins-casc .
```

## jenkins官方修改时区的方法
https://wiki.jenkins.io/display/JENKINS/Change+time+zone

```groovy 
http://localhost:32081/script
print new Date().format("yyyy-MM-dd'T'HH:mm:ssZ")
```

## jenkins 安装方法
https://www.jenkins.io/zh/doc/book/installing/

# https://github.com/jenkinsci/docker-workflow-plugin
## linux
```bash
docker run --rm -p 127.0.0.1:8080:8080 -v /var/run/docker.sock:/var/run/docker.sock --group-add=$(stat -c %g /var/run/docker.sock) jenkinsci/docker-workflow-demo
/usr/bin/docker
```
## mac
```bash
docker run --rm -p 127.0.0.1:8080:8080 -v /var/run/docker.sock:/var/run/docker.sock --group-add=$(stat -f %g /var/run/docker.sock) jenkinsci/docker-workflow-demo
/usr/local/bin/docker
```

## mafeifan 的技术博客
https://blog.mafeifan.com/Jenkins/Jenkins2-%E5%AD%A6%E4%B9%A0%E7%B3%BB%E5%88%971----%E4%BD%BF%E7%94%A8Docker%E6%96%B9%E5%BC%8F%E5%AE%89%E8%A3%85%E6%9C%80%E6%96%B0%E7%89%88Jenkins.html

Run the jenkins master container
```bash
docker run \
      --user jenkins \
      --hostname ci.topflames.com \
      --name jenkins-casc \
      --restart=unless-stopped  \
      -e SLAVE_AGENT_PORT=32082 \
      -p 8080:8080 \
      -p 32082:32082 \
      -v $HOME/.ssh:/var/jenkins_home/.ssh:ro \
      -v $HOME/DevProjectFiles/SupportLibrary/.m2/repository:/var/jenkins_home/.m2/repository:rw \
      -v $HOME/DevProjectFiles/ws-data/jenkins-casc:/var/jenkins_home \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --group-add=$(stat -c %g /var/run/docker.sock) \
      --privileged \
      -d g127/jenkins-casc
```


docker run  --name jenkins --user root --restart=unless-stopped  -p 9081:8080   -v /home/dev/DevProjectFiles/ws-data/jenkins:/var/jenkins_home -d g127/jenkins-casc

Remove the jenkins master container
```bash
docker rm -fv jenkins
```

Remove the jenkins image
```bash
docker rmi -f g127/jenkins-casc
```

Push the jenkins image
docker push g127/jenkins-casc


sudo docker save -o g127-jenkins-casc.tar  g127/jenkins-casc

scp -r g127-jenkins-casc.tar dev@119.3.184.192:~/
