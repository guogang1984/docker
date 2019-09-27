#!/bin/bash

# h.sh  ->  helper.sh
# centos7 docker app script

#
set -e

pushd $(dirname $0) > /dev/null
SCRIPTPATH=$(pwd -P)
popd > /dev/null
SCRIPTFILE=$(basename $0)

# log
function log() {
    echo "================================================================================"
    echo "$(date +'%Y-%m-%d %H:%M:%S%z') [INFO] - $@"
    echo ""
}

# err log
function err() {
    echo "================================================================================"
    echo "$(date +'%Y-%m-%d %H:%M:%S%z') [ERRO] - $@" >&2
}

# TODO 未完成，下面是命令行用法
function installEnv() {
    # ssh-keygen -t rsa -C "agent" -f ~/DevProjectFiles/ws-conf/jenkins/.ssh/agent
    # ssh-keygen -t rsa -C "agent" -f ~/.ssh/agent
    # 在控制台选择对应ECS，然后在列表右侧行操作中选择<重置实例密码>（root的密码）
    # 可选 通过界面上远程登录，首次登录获取 管理密码（远程登录密码）
    # 复制公钥，通过公钥登录  本地复制public-key  ssh-copy-id root@指定ip
    ssh-copy-id root@39.100.234.208  
    # ssh登录到主机
    ssh root@39.100.234.208
    # 设置主机名  项目简称xxx-序号1-ip尾数
    hostnamectl set-hostname xxxapp-1-188
    
    # 如果有购买磁盘，首先使用root用户操作，进行初始化磁盘，以及挂载
    # 格式化和挂载数据盘
    # https://help.aliyun.com/document_detail/25426.html?spm=5176.doc25446.2.3.QrscHW
    # 原地扩容LVM磁盘
    # https://help.aliyun.com/document_detail/35097.html?spm=5176.doc35097.6.720.99VtZ8
    #
    # 检查磁盘空间，运行fdisk -l命令查看实例上的数据盘
    # 运行fdisk -u /dev/vdb命令：分区数据盘
    fdisk -u /dev/vdb
    # 输入p：查看数据盘的分区情况。本示例中，数据盘没有分区。
    # 输入n：创建一个新分区。
    # 输入p：选择分区类型为主分区。
    # 说明 本示例中创建一个单分区数据盘，所以只需要创建主分区。如果要创建四个以上分区，您应该创建至少一个扩展分区，即选择e（extended）。
    # 输入分区编号并按回车键。本示例中，仅创建一个分区，输入1。
    # 输入第一个可用的扇区编号：按回车键采用默认值2048。
    # 输入最后一个扇区编号。本示例中，仅创建一个分区，按回车键采用默认值。
    # 输入p：查看该数据盘的规划分区情况。
    # 输入w：开始分区，并在完成分区后退出。
    # 查看新分区
    fdisk -lu /dev/vdb
    # 格式化 新分区上创建一个ext4文件系统
    mkfs.ext4 /dev/vdb1
    # 新分区写入分区表
    echo /dev/vdb1 /home ext4 defaults 0 0 >> /etc/fstab
    # 挂载文件系统
    mount /dev/vdb1 /home 
    # 
    fdisk -l 
    df -h
    #
    # 安装一些通用软件
    sudo yum install -y wget curl dnsmasq bind-utils net-tools lrzsz rsync zip unzip nc selinux-policy*  yum-utils device-mapper-persistent-data lvm2 iptables-services kernel-devel usbutils pciutils
}

# TODO 未完成，下面是命令行用法
function installUserDev() {
    # sudo权限添加，su需要密码    
    echo  'dev    ALL=(ALL)       ALL'  >> /etc/sudoers
    #  sudo权限添加，su不需要密码    
    echo  'dev    ALL=(ALL)       NOPASSWD:ALL'  >> /etc/sudoers

    # 添加用户
    useradd dev
    # 密码 默认密码 NpSmC2gV
    passwd dev   
    # sudo权限添加
    echo  'dev    ALL=(ALL)       ALL'  >> /etc/sudoers
}

# TODO 未完成，下面是命令行用法
function installDocker() {
    # step 1: 安装必要的一些系统工具
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    # step 2: 添加软件源信息
    sudo yum-config-manager --add-repo \
        http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    # step 3: 更新并安装 Docker-CE
    sudo yum makecache fast
    sudo yum -y install docker-ce
    # step 4: 开启Docker服务
    sudo service docker start 
    sudo systemctl start docker && sudo systemctl enable docker && sudo systemctl status docker
    # docker执行权限分配 sudo usermod -aG docker your-user
    sudo usermod -aG docker $(whoami)
    sudo usermod -aG docker dev
    # 重新登录以后测试
    docker -v

}

# TODO 未完成，下面是命令行用法
function installDockerCompose() {
    # step 1: 方式一 下载最新版本的 docker-compose 到 /usr/bin 目录下
    sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
    # step 1: 方式二 本地上传
    scp -r ~/Downloads/docker-compose-Linux-x86_64 root@111.67.193.151:/usr/bin/docker-compose
    # step 2: 增加执行权限
    sudo chmod +x /usr/bin/docker-compose
    # 重新登录以后测试
    docker -v && docker-compose -v
}

function setMirror() {

# docker 使用 sirius_guo@126.com 私人免费镜像
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://wco14yra.mirror.aliyuncs.com"]
}
EOF

    # 重启docker生效
    sudo systemctl enable docker && sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl status docker
    # 重新登录以后测试
    docker -v && docker-compose -v

}

function pullImages() {
    # docker 镜像
    # tomcat8.5.41  jdk1.8.0_202 latest  mvn3.6.1
    docker pull g127/java
    # nginx
    docker pull g127/nginx 

    # redis 老版本 redis:3.0.7-alpine 新版本 redis:3.2.12-alpine  redis:4.0.14-alpine
    docker pull redis:3.2.12-alpine
    # mysql 5.7 
    docker pull mysql:5.7

    # 其他
    docker pull mongo:latest
    docker pull node:alpine


    # 在docker容器中运行 相关命令 查询 jdk版本和tomcat版本
    docker run -it --rm g127/java catalina.sh version
    # 
    docker run -it --rm g127/nginx nginx -V
    docker run -it --rm g127/nginx ls -l /usr/local/share/GeoIP/
    # 在已经启动的docker容器中运行 相关命令 查询 jdk版本和tomcat版本
    docker exec -t <your container name> 
}


function createDockerNetwork() {
	###
	docker network create app-net
	### Error response from daemon: could not find an available, non-overlapping IPv4 address pool among the defaults to assign to the network
	docker network create --subnet 172.18.0.1/16 app-net
}


function uploadConfigure() {
    # 上传
    scp /Users/gg/DevProjectFiles/ws-my-github/docctFiles.zip dev@111.67.193.151:~/

    unzip DevProjectFiles.zip && rm -rf __* && rm -rf *.zip

}

function startOrStopDb() {
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-db-mysql.yml up -d
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-db-redis3-1.yml up -d
}

function startOrStopWeb() {
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-web1.yml up -d
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-web2.yml up -d
}

function startOrStopNginx() {
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-nginx.yml up -d

    docker exec -it web-nginx nginx -s reload
}

function pullPorject() {
    mkdir -p ~/DevProjectFiles/ws-release/
    # rsync://downloadUser@release.topflames.com:873/release
    chmod 700 ~/DevProjectFiles/ws-conf/rsync/downloadUser.pas
    chmod 700 ~/DevProjectFiles/ws-conf/rsync/exclude.list
    rsync --no-iconv -avzP --progress --delete \
          --password-file=/home/dev/DevProjectFiles/ws-conf/rsync/downloadUser.pas \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          rsync://downloadUser@release.topflames.com:873/release/qifa-service \
          /home/dev/DevProjectFiles/ws-release/

    rsync --no-iconv -avzP --progress --delete \
          --password-file=/home/dev/DevProjectFiles/ws-conf/rsync/downloadUser.pas \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          rsync://downloadUser@release.topflames.com:873/release/qifa-console \
          /home/dev/DevProjectFiles/ws-release/ 

    ssh dev@39.100.234.106 \
    rsync --no-iconv -avzP --progress --delete \
          --password-file=/home/dev/DevProjectFiles/ws-conf/rsync/downloadUser.pas \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          rsync://downloadUser@release.topflames.com:873/release/qifa-site \
          /home/dev/DevProjectFiles/ws-release/ 

    # 本地 service 1
    rsync --no-iconv -avzP --progress --delete \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          /home/dev/DevProjectFiles/ws-release/qifa-service/target/qifa-service-1.0-SNAPSHOT/ \
          /home/dev/DevProjectFiles/ws-root/qifa-service-1/

    # 本地 service 2
    rsync --no-iconv -avzP --progress --delete \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          /home/dev/DevProjectFiles/ws-release/qifa-service/target/qifa-service-1.0-SNAPSHOT/ \
          /home/dev/DevProjectFiles/ws-root/qifa-service-2/

    # 本地 console
    ssh dev@39.100.234.106 \
    rsync --no-iconv -avzP --progress --delete \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          /home/dev/DevProjectFiles/ws-release/qifa-console/target/ \
          /home/dev/DevProjectFiles/ws-root/www/console.app.com/

    # 本地 site
    rsync --no-iconv -avzP --progress --delete \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          /home/dev/DevProjectFiles/ws-release/qifa-site/target/ \
          /home/dev/DevProjectFiles/ws-root/www/www.app.com/


    mkdir -p  /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost18081/ && \
     echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/qifa-service-1\" />" > /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost18081/qifa-service.xml

    mkdir -p  /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost18082/ && \
     echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/qifa-service-2\" />" > /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost18082/qifa-service.xml

tee  /home/dev/DevProjectFiles/ws-conf/tomcat8/context.xml.redis <<-'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<!-- The contents of this file will be loaded for each web application -->
<Context>

    <!-- Default set of monitored resources. If one of these changes, the    -->
    <!-- web application will be reloaded.                                   -->
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
    <WatchedResource>${catalina.base}/conf/web.xml</WatchedResource>

    <!-- Uncomment this to disable session persistence across Tomcat restarts -->
    <!--
    <Manager pathname="" />
    -->
    
    <Valve className="tomcat.request.session.redis.SessionHandlerValve" />
    <Manager className="tomcat.request.session.redis.SessionManager" /> 
</Context>
EOF

}


