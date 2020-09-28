FROM jenkins/jenkins:2.257-alpine

MAINTAINER gg  <guogang1984@gmail.com>

USER root

# APACHE_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/apache
# APACHE_MIRROR=https://archive.apache.org/dist
ENV TZ=Asia/Shanghai \
    PATH=${PATH}:/opt/maven/bin \
    SLAVE_AGENT_PORT=50000 \
    CASC_JENKINS_CONFIG=$JENKINS_HOME/casc_configs \
    JAVA_OPTS=" -Djava.security.egd=file:/dev/./urandom -Duser.timezone=GMT+08 -Dorg.apache.commons.jelly.tags.fmt.timeZone=GMT+08 -Djenkins.install.runSetupWizard=false " \
    GITLAB_PERSONAL_ACCESS_TOKEN="123456" 

# install-plugins
COPY ref/install-plugins-customize.sh /usr/local/bin/install-plugins.sh

# Plugins
# the grep command allows to ignore all comments in the plugins.txt file
COPY ref/plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN echo 'run script' \
    # add jenkins user
    && addgroup jenkins root && echo $(id jenkins) \
    # exec install-plugins
    && xargs install-plugins.sh `grep -v '^#' /usr/share/jenkins/ref/plugins.txt` \
    # init folder
    && mkdir -p /usr/share/jenkins/ref/init.groovy.d/ /usr/share/jenkins/ref/casc_configs/ \
    && chown -R jenkins:jenkins /usr/share/jenkins/ref \
    # clean tmp
    && rm -rf /tmp/* /var/cache/apk/*

# Security
COPY ref/init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Configuration-as-code
COPY ref/casc_configs/ /usr/share/jenkins/ref/casc_configs/

USER jenkins

# Disable signature checking on DownloadService
#ENV JAVA_OPTS -Dhudson.model.DownloadService.noSignatureCheck=true
# ENTRYPOINT
ENTRYPOINT ["tini", "--", "/usr/local/bin/jenkins.sh"]
