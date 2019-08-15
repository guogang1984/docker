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
    # 在控制台选择对应ECS然后重置实例密码（root的密码）
    # 可选 通过界面上远程登录，首次登录获取 管理密码（远程登录密码）
    # 复制公钥，通过公钥登录  本地复制public-key  ssh-copy-id root@指定ip
    ssh-copy-id root@39.100.234.208  
    # ssh登录到主机
    ssh root@39.100.234.208
    # 设置主机名
    hostnamectl set-hostname xxx-app
    # 检查磁盘空间
    fdisk -l
    df -h
    # 如果有购买磁盘，首先使用root用户操作，进行初始化磁盘，以及挂载
    # 格式化和挂载数据盘
    # https://help.aliyun.com/document_detail/25426.html?spm=5176.doc25446.2.3.QrscHW
    # 原地扩容LVM磁盘
    # https://help.aliyun.com/document_detail/35097.html?spm=5176.doc35097.6.720.99VtZ8
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
    # docker执行权限分配 sudo usermod -aG docker your-user
    usermod -aG docker dev
    # usermod -aG docker $(whoami)
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
}

# TODO 未完成，下面是命令行用法
function installDockerCompose() {
    # step 1: 方式一 下载最新版本的 docker-compose 到 /usr/bin 目录下
    sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
    # step 1: 方式二 本地上传
    scp -r ~/Downloads/docker-compose-Linux-x86_64 root@111.67.193.151:/usr/bin/docker-compose
    # step 2: 增加执行权限
    sudo chmod +x /usr/bin/docker-compose
}

function setMirror() {

# docker
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://wco14yra.mirror.aliyuncs.com"]
}
EOF

sudo systemctl enable docker;
sudo systemctl daemon-reload;
sudo systemctl restart docker;
sudo systemctl status docker;

}

function pullImages() {
    # docker 镜像
    # tomcat8.5.41  jdk1.8.0_202 latest  mvn3.6.1
    sudo docker pull g127/java
    # nginx
    sudo docker pull g127/nginx 

    # redis 老版本 redis:3.0.7-alpine 新版本 redis:3.2.12-alpine  redis:4.0.14-alpine
    sudo docker pull redis:3.2.12-alpine
    # mysql 5.7 
    sudo docker pull mysql:5.7

    # 其他
    sudo docker pull mongo:latest
    sudo docker pull node:alpine


    # 在docker容器中运行 相关命令 查询 jdk版本和tomcat版本
    sudo docker run -it --rm g127/java catalina.sh version
    # 
    sudo docker run -it --rm g127/nginx nginx -V
    sudo docker run -it --rm g127/nginx ls -l /usr/local/share/GeoIP/
    # 在已经启动的docker容器中运行 相关命令 查询 jdk版本和tomcat版本
    sudo  docker exec -t <your container name> 
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
}


