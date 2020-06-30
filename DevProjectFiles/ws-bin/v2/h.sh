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

function toggleNetwork(){
    # CENTOS 7 下service network restart
    # systemctl status network.service 无法启动
    # 执行 /etc/rc.d/init.d/network start
    # 必须先查询出 自动获取的网卡地址 ip 网关 dns等
    # 然后备份 /etc/sysconfig/network-scripts 
    # 修改 ifcfg-xxx 为 “静态IP地址”
    # 
    #   
    #   BOOTPROTO="static"         # 使用静态IP地址，默认为dhcp
    #   ONBOOT=yes
    #   
    #   IPADDR=192.168.0.165
    #   NETMASK=255.255.255.0
    #   GATEWAY=192.168.0.1
    #   DNS1=114.114.114.114
    #   HWADDR=fa:16:3e:c3:89:02  # 一定要加上
    #  
    # 设定开机启动一个名为NetworkManager-wait-online服务
    # 命令为：systemctl enable NetworkManager-wait-online.service
    # 查看/etc/sysconfig/network-scripts下，将其余无关的网卡位置文件全删掉，避免不必要的影响
    # 重启 reboot -f
}

# TODO 未完成，下面是命令行用法
function installCPanel() {
    # 设置主机名  项目简称xxx-序号1-ip尾数
    # hostnamectl set-hostname xxxapp-1-188

    # 注：在安装cPanel的时候，可能出现的一些问题：
    # 1、主机名问题:
    hostname localhost.localdomain
    # 2、重新执行安装：
    rm -rf /root/installer.lock
    sh latest 执行安装脚本
    # 4、关闭SELinux
    # 编辑 /etc/selinux/config文件
    # 修改为 SELINUX=disabled
    # 5、停用防火墙
    chkconfig iptables off
    service iptables stop
    # 6.无法和cpanel.net建立连接，ping提示ping: unknown host cpanel.net，这是dns的问题，修改/etc/resolv.conf，将nameserver 设置为 8.8.8.8

    # cpanel安装时出现这个错误
    # Fatal! Perl must be installed before proceeding!
    # 可以先
    # yum install perl
    # 然后再重新安装就可以了

    yum -y install screen perl
    screen -S cpanel
    cd /home
    wget -N http://httpupdate.cpanel.net/latest
    # sh latest 2>&1 | tee ./cPanel-Install.log
    # nohup sh latest > ./cPanel-Install.log 2>&1 &
}

# TODO 未完成，下面是命令行用法
function installEnv() {
    # ssh-keygen -t rsa -C "agent" -f ~/DevProjectFiles/ws-conf/jenkins/.ssh/agent
    # ssh-keygen -t rsa -C "agent" -f ~/.ssh/agent
    # 在控制台选择对应ECS，然后在列表右侧行操作中选择<重置实例密码>（root的密码）
    # 可选 通过界面上远程登录，首次登录获取 管理密码（远程登录密码）
    # 复制公钥，通过公钥登录  本地复制public-key  ssh-copy-id root@指定ip
    # ssh-copy-id dev@39.100.234.208 
    # ssh-copy-id -i  ~/.ssh/agent root@39.100.234.208
    #
    # docker exec -it jenkins-ci ssh -i /var/jenkins_home/.ssh/agent dev@121.40.224.188
    #
    # ssh-add命令是把专用密钥添加到ssh-agent的高速缓存中。该命令位置在/usr/bin/ssh-add
    # ssh-add  -l：显示ssh-agent中的密钥
    # 1、把专用密钥添加到 ssh-agent 的高速缓存中：
    # ssh-add ~/.ssh/id_dsa
    # 2、从ssh-agent中删除密钥
    # ssh-add -d ~/.ssh/id_xxx.pub
    # 3、查看ssh-agent中的密钥：
    # ssh-add -l
    # ssh-add ~/.ssh/agent
    # 
    # 问题:执行ssh-add时出现Could not open a connection to your authentication agent
    # eval `ssh-agent`
    ssh-copy-id root@39.100.234.208  
    # 增加主机信任
    # ssh登录到主机
    ssh root@39.100.234.208
    # 跳板登录
    ssh -o "ProxyCommand ssh -p 1098 lmx@proxy.machine nc -w 1 %h %p" -p 1098 lmx@target.machine
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
    # dns
    # 看netmask  ,dns
    ifconfig -a 
    # 看网关
    netstat   -rn 
    # 显示当前网络连接
    sudo nmcli con show -active
    sudo nmcli con show eno16777984
    # 显示设备的连接状态
    sudo nmcli dev status
    sudo nmcli dev show eno16777984
    # 修改当前网络连接对应的DNS服务器，这里的网络连接可以用名称或者UUID来标识
    sudo nmcli con mod eth0 ipv4.dns "114.114.114.114 8.8.8.8"
    sudo nmcli con mod "Wired connection 3" +ipv4.dns 8.8.8.8
    # 将dns配置生效
    sudo nmcli con up eth0
    # 重新加载配置网络配置文件
    sudo nmcli con reload
    #
    # 安装一些通用软件
    sudo yum install -y wget curl dnsmasq bind-utils net-tools lrzsz rsync zip unzip nc selinux-policy*  yum-utils device-mapper-persistent-data lvm2 iptables-services kernel-devel usbutils pciutils
    # 安装所有32位程序需要组件的方法
    # <!--ia32-libs.i686 //是ubuntu系列下的,而且13.10之后的ubuntu貌似也没这个了-->
    # sudo yum install xulrunner.i686  
}

# TODO 未完成，下面是命令行用法
function installUserDev() {
    # sudo权限添加，su需要密码    
    # echo  'dev    ALL=(ALL)       ALL'  >> /etc/sudoers
    #  sudo权限添加，su不需要密码    
    echo  'dev    ALL=(ALL)       NOPASSWD:ALL'  >> /etc/sudoers

    # 添加用户
    useradd dev
    # 密码 默认密码 
    passwd dev   
    # root
    sudo usermod -aG docker $(whoami)
}

# TODO 未完成，下面是命令行用法
# https://github.com/docker/docker-install/blob/master/rootless-install.sh
# http://get.daocloud.io/#install-docker
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
    # sudo usermod -aG docker dev
    # 重新登录以后测试
    docker -v

}

# TODO 未完成，下面是命令行用法
function installDockerMachine() {
    # Install Docker Machine If you are running Linux:
    base=https://github.com/docker/machine/releases/download/v0.16.0 &&
      curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
      sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
      chmod +x /usr/local/bin/docker-machine

    # Install Docker Machine If you are running macOS:
    base=https://github.com/docker/machine/releases/download/v0.16.0 &&
      curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/usr/local/bin/docker-machine &&
      chmod +x /usr/local/bin/docker-machine

    # If you are running Windows with Git BASH:
    base=https://github.com/docker/machine/releases/download/v0.16.0 &&
      mkdir -p "$HOME/bin" &&
      curl -L $base/docker-machine-Windows-x86_64.exe > "$HOME/bin/docker-machine.exe" &&
      chmod +x "$HOME/bin/docker-machine.exe"

    #
}

# TODO 未完成，下面是命令行用法
function installDockerCompose() {
    # step 1: 方式一 下载最新版本的 docker-compose 到 /usr/bin 目录下
    sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
    # step 1: 方式二 本地上传
    scp -r  -P 18022 ~/Downloads/docker-compose-Linux-x86_64 root@58.49.165.253:/usr/bin/docker-compose
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

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://wco14yra.mirror.aliyuncs.com", "http://f1361db2.m.daocloud.io", "https://7hn9mjqg.mirror.aliyuncs.com"]
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


    # 如果网络不好，使用save 和 load
    sudo docker save -o g127-java.tar  g127/java
    sudo docker save -o g127-nginx.tar g127/nginx
    sudo docker save -o g127-redis.tar redis:3.2.12-alpine
    sudo docker save -o g127-mysql.tar mysql:5.7
    sudo docker save -o sonatype-nexus.tar sonatype/nexus:2.14.16
    # 上传目录下的tar文件到服务器。
    scp  -P 18022 *.tar dev@58.49.165.253:~/ 
    scp  -P 22 *.tar dev@121.36.196.18:~/ 
    scp  -P 11433 sonatype-nexus.tar dev@58.218.126.33:~/ 
    scp /Users/gg/DevProjectFiles/ws-my-github/docctFiles.zip dev@111.67.193.151:~/

    sudo docker load -i g127-java.tar 
    sudo docker load -i g127-nginx.tar 
    sudo docker load -i g127-redis.tar 
    sudo docker load -i g127-mysql.tar 
    sudo docker load -i sonatype-nexus.tar
    #
    docker rm -fv $(docker ps -a | grep "Exited" | awk '{print $1 }') 
    #
    docker rmi $(docker images | grep "none" | awk '{print $3}')
    # 在docker容器中运行 相关命令 查询 jdk版本和tomcat版本
    docker run -it --rm g127/java catalina.sh version
    # 
    docker run -it --rm g127/nginx nginx -V
    docker run -it --rm g127/nginx ls -l /usr/local/share/GeoIP/
    # redis
    docker run -it --rm redis:3.2.12-alpine ls -l /usr/local/etc/redis/
    # nexus
    docker run -it sonatype/nexus ./bin/nexus status

    # 在已经启动的docker容器中运行 相关命令 查询 jdk版本和tomcat版本
    docker exec -t <your container name> 


    # 修改数据库配置
    grep "jdbc:mysql://127.0.0.1" DevProjectFiles/ws-root/webapps-18081* -R | awk -F: '{print $1}' | sort | uniq | xargs sed -i 's#jdbc:mysql://127.0.0.1#jdbc:mysql://mysql#g'
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
    scp /Users/gg/Downloads/docker-output.zip dev@111.67.193.151:~/
    # zip命令
    zip -r web1.zip tmp/logs/web1/**
    # 
    unzip DevProjectFiles.zip && rm -rf __* && rm -rf *.zip

}

function startOrStopDb() {
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-db-mysql.yml up -d
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-db-redis3-1.yml up -d
}

function startOrStopNginx() {
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-nginx.yml up -d

    docker exec -it web-nginx chmod -R 755 /usr/local/share/GeoIP/

    docker exec -it web-nginx ls -l /usr/local/share/GeoIP/

    docker exec -it web-nginx nginx -V 

    docker exec -it web-nginx nginx -s reload

    docker exec -it web-nginx ls -l /usr/local/openresty/nginx/modules
}

function startOrStopWeb() {
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-web1.yml up -d
    #
    docker-compose -f ~/DevProjectFiles/ws-docker/docker-compose-web2.yml up -d
}

function pullPorject() {
    mkdir -p ~/DevProjectFiles/ws-release/
    # rsync://downloadUser@release.topflames.com:873/release
    chmod 700 ~/DevProjectFiles/ws-conf/rsync/downloadUser.pas
    chmod 700 ~/DevProjectFiles/ws-conf/rsync/exclude.list
    rsync --no-iconv -avzP --progress --delete \
          --password-file=/home/dev/DevProjectFiles/ws-conf/rsync/downloadUser.pas \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          rsync://downloadUser@release.topflames.com:873/release/fileResources \
          /home/dev/DevProjectFiles/ws-release/

    rsync --no-iconv -avzP --progress --delete \
          --password-file=/home/dev/DevProjectFiles/ws-conf/rsync/downloadUser.pas \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          rsync://downloadUser@release.topflames.com:873/release/topflames-oa-dev31 \
          /home/dev/DevProjectFiles/ws-release/

    rsync --no-iconv -avzP --progress --delete \
          --password-file=/home/dev/DevProjectFiles/ws-conf/rsync/downloadUser.pas \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          rsync://downloadUser@release.topflames.com:873/release/yyfb-console-web \
          /home/dev/DevProjectFiles/ws-release/ 

    rsync --no-iconv -avzP --progress --delete \
          --password-file=/home/dev/DevProjectFiles/ws-conf/rsync/downloadUser.pas \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          rsync://downloadUser@release.topflames.com:873/release/yyfb-ui \
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
          /home/dev/DevProjectFiles/ws-release/yyfb-service/target/yyfb-service-1.0-SNAPSHOT/ \
          /home/dev/DevProjectFiles/ws-root/yyfb-service-1/

    # 本地 service 2
    rsync --no-iconv -avzP --progress --delete \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          /home/dev/DevProjectFiles/ws-release/yyfb-service/target/yyfb-service-1.0-SNAPSHOT/ \
          /home/dev/DevProjectFiles/ws-root/yyfb-service-2/

    # 本地 console
    ssh dev@39.100.234.106 \
    rsync --no-iconv -avzP --progress --delete \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          /home/dev/DevProjectFiles/ws-release/yyfb-console-web/target/ \
          /home/dev/DevProjectFiles/ws-root/www/console.app.com/

    # 本地 site
    rsync --no-iconv -avzP --progress --delete \
          --exclude-from=/home/dev/DevProjectFiles/ws-conf/rsync/exclude.list \
          /home/dev/DevProjectFiles/ws-release/yyfb-ui/target/ \
          /home/dev/DevProjectFiles/ws-root/www/www.app.com/


    mkdir -p  /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost18081/ && \
     echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/xzoa-service-1\" />" > /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost18081/xzoa-service.xml

    mkdir -p  /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost18082/ && \
     echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/xzoa-service-2\" />" > /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost18082/xzoa-service.xml


    mkdir -p  /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost28081/ && \
     echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/xzoa-service-dev-1\" />" > /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost28081/jyb-service-dev.xml

    mkdir -p  /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost28082/ && \
     echo "<Context reloadable=\"false\" docBase=\"/DevProjectFiles/ws-root/xzoa-service-dev-2\" />" > /home/dev/DevProjectFiles/ws-conf/tomcat8/localhost28082/jyb-service-dev.xml



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


# tee  /home/dev/DevProjectFiles/ws-root/xzoa-service-1/WEB-INF/classes/application.properties <<-'EOF'
tee  application.properties <<-'EOF'
#--------------------------------
# application settings
#--------------------------------
app.name=lkyoa-service

#--------------------------------
# login settings
#--------------------------------
# login settings begin 
app.captcha.enabled=false
app.register.enabled=false
app.qrCode.enabled=false
app.qrCode.url=https://www.pgyer.com/niiH
app.log.parent.path=/tmp/logs
app.log.name=lkyoa-service
#login settings end 

#--------------------------------
# mysql database settings
#--------------------------------
#mysql database settings begin
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://mysql:3306/lkyoa-service?useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull&useSSL=false&nullCatalogMeansCurrent=true
jdbc.username=root
jdbc.password=oMqiVy#oF603UZve
#mysql database settings end

#--------------------------------
# connection pool settings
#--------------------------------
#connection pool settings
jdbc.pool.maxIdle=10
jdbc.pool.maxActive=200

#--------------------------------
# fileResources settings 
#--------------------------------
#fileResources settings begin
uploadPath=/DevProjectFiles/ws-root/fileResources
#fileResources settings end

#--------------------------------
# notification setting 
#--------------------------------
notification.push.enabled=true
notification.appNames=lkyoa

#--------------------------------
# redis settings 
#--------------------------------
redis.enabled=true
redis.host=redis3
redis.port=6379  
#redis.pass=123456
redis.timeout=1000
EOF

}


function uploadProperties() {
    # 上传
tee  /home/dev/DevProjectFiles/ws-root/www/www.app.com/application.properties.json <<-'EOF'
{
  "comment": "通用配置参数，后台接口地址",
  "BASE_API": "http://58.218.126.33:10050/xzoa-service",
  "NOTIFICATION_API": "http://58.218.126.33:10050"
}
EOF

}


function cert() {
  # https://github.com/Neilpang/acme.sh/wiki/%E8%AF%B4%E6%98%8E
  # 初始化
  curl  https://get.acme.sh | sh
  # 验证
  acme.sh  --issue  -d jiayoubao.hyszapp.cn  --webroot  /home/dev/DevProjectFiles/ws-root/www/www.app.com/

  mkdir -p /home/dev/DevProjectFiles/ws-conf/nginx/vhosts/cert/jiayoubao.hyszapp.cn/
  # 安装
  acme.sh  --installcert  -d  jiayoubao.hyszapp.cn   \
          --key-file   /home/dev/DevProjectFiles/ws-conf/nginx/vhosts/cert/jiayoubao.hyszapp.cn/jiayoubao.hyszapp.cn.key \
          --fullchain-file /home/dev/DevProjectFiles/ws-conf/nginx/vhosts/cert/jiayoubao.hyszapp.cn/fullchain.cer \
          --reloadcmd  "docker exec -it web-nginx nginx -s reload"
  # 手工更新证书
  acme.sh  --renew  -d  jiayoubao.hyszapp.cn --force
}

