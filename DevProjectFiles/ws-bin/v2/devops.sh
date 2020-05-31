# rm -rf ~/DevProjectFiles/ws-conf/gitlab
# rm -rf ~/DevProjectFiles/ws-data/gitlab
#
# mkdir -p ~/DevProjectFiles/ws-conf/gitlab
# mkdir -p ~/DevProjectFiles/ws-data/gitlab
# mkdir -p ~/tmp/logs/gitlab
#
# docker pull gitlab/gitlab-ce:11.11.8-ce.0
# Gitlab http://$HOST_NAME:9080/

docker run \
  --hostname dev.topflames.com \
  --name gitlab \
  --restart=unless-stopped  \
  -e TZ='Asia/Shanghai' \
  -e GITLAB_BACKUP_SCHEDULE='daily' \
  -e GITLAB_BACKUP_TIME='01:00' \
  -e GITLAB_OMNIBUS_CONFIG="external_url 'http://119.3.184.192:9080'; nginx['listen_port'] = 9080; gitlab_rails['gitlab_shell_ssh_port'] = 9022; gitlab_rails['time_zone'] = 'Asia/Shanghai';  gitlab_rails['smtp_enable'] = true; gitlab_rails['smtp_address'] = 'smtp.exmail.qq.com'; gitlab_rails['smtp_port'] = 25; gitlab_rails['smtp_user_name'] = 'support@topflames.com'; gitlab_rails['smtp_password'] = 'Tf123456'; gitlab_rails['smtp_domain'] = 'exmail.qq.com'; gitlab_rails['smtp_authentication'] = :plain; gitlab_rails['smtp_enable_starttls_auto'] = true; gitlab_rails['smtp_tls'] = false;  gitlab_rails['gitlab_email_enabled'] = true; gitlab_rails['gitlab_email_from'] = 'support@topflames.com'; gitlab_rails['gitlab_email_display_name'] = '驼峰支持'; gitlab_rails['gitlab_email_reply_to'] = 'support@topflames.com';" \
  -p 9080:9080 \
  -p 9022:22 \
  -v ~/DevProjectFiles/ws-conf/gitlab:/etc/gitlab \
  -v ~/DevProjectFiles/ws-data/gitlab:/var/opt/gitlab \
  -v ~/tmp/logs/gitlab:/var/log/gitlab \
  --privileged \
  -d gitlab/gitlab-ce:11.11.8-ce.0

# rm -rf ~/DevProjectFiles/ws-data/rancher
# mkdir -p ~/DevProjectFiles/ws-data/rancher
# rm -rf ~/tmp/logs/auditlog
# mkdir -p ~/tmp/logs/auditlog
# docker pull rancher/rancher:stable
# 
docker run \
  --name rancher \
  --restart=unless-stopped \
  -e TZ='Asia/Shanghai' \
  -p 80:80 -p 443:443 \
  -v ~/DevProjectFiles/ws-data/rancher:/var/lib/rancher/ \
  -v ~/tmp/logs/auditlog:/var/log/auditlog \
  -e CATTLE_SYSTEM_CATALOG=bundled \
  -e AUDIT_LEVEL=3 \
  --privileged \
  -d rancher/rancher:stable


# 
# sudo mkdir -p ~/DevProjectFiles/ws-data/jenkins
# sudo rm -rf ~/DevProjectFiles/ws-data/jenkins
# sudo mkdir -p ~/DevProjectFiles/ws-data/jenkins
# docker pull jenkins/jenkins:lts-alpine
# Jenkins http://$HOST_NAME:8080/
# 官方镜像
# https://github.com/jenkinsci/docker
# 插件下载慢 暂时解决方式 使用 https://gitee.com/jenkins-zh/jenkins-formulas 定制版本。
# 插件管理高级页面
# http://$HOST_NAME:8080/pluginManager/advanced
# 中文插件
# https://mirrors.tuna.tsinghua.edu.cn/jenkins/plugins/localization-zh-cn/latest/localization-zh-cn.hpi
# 配置及代码 casc
# https://mirrors.tuna.tsinghua.edu.cn/jenkins/plugins/configuration-as-code/latest/configuration-as-code.hpi
# 触发器 generic-webhook-trigger
# https://mirrors.tuna.tsinghua.edu.cn/jenkins/plugins/generic-webhook-trigger/latest/generic-webhook-trigger.hpi
# 
# http://ci.topflames.com:8080/script
# 使用Jenkins脚本命令行批量修改任务设置清理磁盘空间
# import hudson.tasks.LogRotator
# Jenkins.instance.allItems(Job).each { job ->
#   println "$job.builds.number $job.name"
#   if ( job.isBuildable() && job.supportsLogRotator()) {
#     // 注释if所有任务统一设置策略，去掉注释后只更改没有配置策略的任务
#     //if ( job.getProperty(BuildDiscarderProperty) == null) {
#       job.setLogRotator(new LogRotator (60, 30, 30, 3))
#     //}
#       job.logRotate() //立马执行Rotate策略
#     println "$job.builds.number $job.name 磁盘回收已处理"
#   } else { println "$job.name 未修改，已跳过" }
# }
# return;
#
# 解释说明
# LogRotator构造参数分别为：
# 
# daysToKeep: 构建记录将保存的天数
# numToKeep: 最多此数目的构建记录将被保存
# artifactDaysToKeep: 比此早的发布包将被删除，但构建的日志、操作历史、报告等将被保留
# artifactNumToKeep: 最多此数目的构建将保留他们的发布包
#
# // jenkins  批量删除构建历史
# def jobName = "sfjd-service"
# def maxNumber = 100
# 
# def job = Jenkins.instance.getItemByFullName(jobName)
# 
# job.builds.findAll {
#   it.number <= maxNumber
# }.each {
#   it.delete()
# }
# 
# job.nextBuildNumber = 1
# job.save()
#
#
# def maxNumber = 300
# Jenkins.instance.allItems(Job).each { job ->
#   println "$job.builds.number $job.name"
#
#   job.builds.findAll {
#     it.number <= maxNumber
#   }.each {
#     it.delete()
#     println "delete $job.builds.number $job.name"
#   }
#   job.nextBuildNumber = 1
#   job.save()
# }
# return;
#
# 查看/var/lib/目录下空间大的前几个
# sudo du -sh ~/DevProjectFiles/ws-conf/jenkins/* | sort -rn | head
# sudo du -h --max-depth=1 查看当前目录下一级子目录大小
# sudo du -h --max-depth=1| | sort -rn 查看当前目录下一级子目录大小，倒序排序
# sudo du -h --max-depth=1 /path 查看/path目录下的一级子目录大小
# curl -X POST -u admin:admin123 http://119.3.184.192:8080/configuration-as-code/apply
# https://jenkins-zh.cn/
JENKINS_HOME=~/DevProjectFiles/ws-data/jenkins
sudo rm -rf $JENKINS_HOME \
  && sudo mkdir -p $JENKINS_HOME/updates/ \
  \
  && sudo curl -L https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json \
      -o $JENKINS_HOME/updates/default.json 

sudo sed -i 's/http:\/\/updates.jenkins-ci.org\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' \
        $JENKINS_HOME/updates/default.json  \
  && sudo sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' \
         $JENKINS_HOME/updates/default.json

sudo cat $JENKINS_HOME/secrets/initialAdminPassword

docker run \
  --user root \
  --hostname ci.topflames.com \
  --name jenkins \
  --restart=unless-stopped  \
  -e TZ='Asia/Shanghai' \
  -e JAVA_OPTS=' -Djava.security.egd=file:/dev/./urandom -Duser.timezone=GMT+08 ' \
  -e JENKINS_UC='https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates' \
  -e JENKINS_UC_DOWNLOAD='https://mirrors.tuna.tsinghua.edu.cn/jenkins' \
  -e JENKINS_OPTS='-Djenkins.install.runSetupWizard=false' \
  -p 8080:8080 \
  -p 50000:50000 \
  -v ~/DevProjectFiles/ws-data/jenkins:/var/jenkins_home \
  --privileged \
  -d jenkins/jenkins:lts-alpine

# 
# sudo rm -rf ~/DevProjectFiles/ws-data/nexus3
# mkdir -p ~/DevProjectFiles/ws-data/nexus3
# sudo chown -R 200 ~/DevProjectFiles/ws-data/nexus3
# docker pull sonatype/nexus3:3.22.0
#
# Nexus3 http://$HOST_NAME:8081/
# 关于 仓库脚本导入 https://github.com/sonatype-nexus-community/nexus-repository-import-scripts
docker rm -fv nexus3 
N3_DATA=~/DevProjectFiles/ws-data/nexus3
sudo rm -rf $N3_DATA \
  && sudo mkdir -p $N3_DATA \
  && sudo chown -R 200 $N3_DATA \
  && sudo ls -l $N3_DATA

sudo cat $N3_DATA/admin.password

docker run \
  --user 200 \
  --hostname nexus3.topflames.com \
  --name nexus3 \
  --restart=unless-stopped  \
  -e TZ='Asia/Shanghai' \
  -e JAVA_OPTS=' -Djava.io.tmpdir=/tmp/java/tmp -Djava.security.egd=file:/dev/./urandom -Duser.timezone=GMT+08 ' \
  -p 8081:8081 \
  -v ~/DevProjectFiles/ws-data/nexus3:/nexus-data \
  --privileged \
  -d sonatype/nexus3:3.22.0

docker rm -fv nexus2
N2_DATA=~/DevProjectFiles/ws-data/nexus2
sudo rm -rf $N2_DATA \
  && sudo mkdir -p $N2_DATA \
  && sudo chown -R 200 $N2_DATA \
  && sudo ls -l $N2_DATA

docker run \
  --user 200 \
  --hostname nexus2.topflames.com \
  --name nexus2 \
  --restart=unless-stopped  \
  -e TZ='Asia/Shanghai' \
  -e JAVA_OPTS=' -Djava.io.tmpdir=/tmp/java/tmp -Djava.security.egd=file:/dev/./urandom -Duser.timezone=GMT+08 ' \
  -p 8082:8081 \
  -v ~/DevProjectFiles/ws-data/nexus2:/sonatype-work \
  --privileged \
  -d sonatype/nexus:2.14.16
