ARG jenkins_tag=lts-alpine

# docker pull jenkins/jenkins:lts-alpine
FROM jenkins/jenkins:$jenkins_tag

MAINTAINER gg  <guogang1984@gmail.com>

USER root

# APACHE_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/apache
# APACHE_MIRROR=https://archive.apache.org/dist
ENV TZ=Asia/Shanghai \
    TSINGHUA_MIRROR=https://mirrors.tuna.tsinghua.edu.cn \
    MAVEN_VERSION=3.6.3 \
    MAVEN_HOME=/opt/maven \
    PATH=${PATH}:/opt/maven/bin \
    MAVEN_VERSION=3.6.3 \
    SLAVE_AGENT_PORT=50000 \
    CASC_JENKINS_CONFIG=$JENKINS_HOME/casc_configs \
    JAVA_OPTS=" -Djava.security.egd=file:/dev/./urandom -Duser.timezone=GMT+08 -Dorg.apache.commons.jelly.tags.fmt.timeZone=GMT+08 -Djenkins.install.runSetupWizard=false " \
    GITLAB_PERSONAL_ACCESS_TOKEN="123456" 


# install-plugins
COPY ref/install-plugins-customize.sh /usr/local/bin/install-plugins.sh

# Plugins
COPY ref/plugins.txt /usr/share/jenkins/ref/plugins.txt

# the grep command allows to ignore all comments in the plugins.txt file
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    echo 'apk --update add git less openssh' && \
    echo 'git --version' && \
    echo 'apk --update add apache2 apache2-utils apache2-webdav mod_dav_svn subversion' && \
    echo 'svn --version' && \
    curl -fsSL -o /tmp/apache-maven.tar.gz ${TSINGHUA_MIRROR}/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    gunzip /tmp/apache-maven.tar.gz && \
    tar -C /opt -xf /tmp/apache-maven.tar && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} ${MAVEN_HOME} && \
    mvn -v && \
    curl -fsSL -o /tmp/docker.tgz ${TSINGHUA_MIRROR}/docker-ce/linux/static/stable/x86_64/docker-18.09.9.tgz && \
    tar -C /tmp -xzvf /tmp/docker.tgz && \
    mv /tmp/docker/* /usr/local/bin/  && \
    docker -v && \
    addgroup jenkins root && \
    echo $(id jenkins) && \ 
    xargs install-plugins.sh `grep -v '^#' /usr/share/jenkins/ref/plugins.txt` && \
    mkdir -p /usr/share/jenkins/ref/init.groovy.d/ && \
    mkdir -p /usr/share/jenkins/ref/casc_configs/ && \
    chown -R jenkins:jenkins /usr/share/jenkins/ref && \
    rm -rf /tmp/* /var/cache/apk/*

# Security
COPY ref/init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Configuration-as-code
COPY ref/casc_configs/ /usr/share/jenkins/ref/casc_configs/

# COPY alpine/etc/localtime  /etc/localtime

USER jenkins

# Disable signature checking on DownloadService
#ENV JAVA_OPTS -Dhudson.model.DownloadService.noSignatureCheck=true

# ENTRYPOINT
ENTRYPOINT ["tini", "--", "/usr/local/bin/jenkins.sh"]

