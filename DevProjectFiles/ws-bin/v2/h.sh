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

#
function vimGBK() {
    vim ~/.vimrc
    set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
    set termencoding=utf-8
    set encoding=utf-8
}

# err log
function err() {
    echo "================================================================================"
    echo "$(date +'%Y-%m-%d %H:%M:%S%z') [ERRO] - $@" >&2
}

function Ip() {
    # linux服务器查看外网ip
    curl -s icanhazip.com
}


function checkoutTcp() {
    # https://www.cnblogs.com/QLeelulu/p/3601499.html
    # Nginx做前端Proxy时TIME_WAIT过多的问题
    # 由于nginx代理使用了短链接的方式和后端交互的原因，使得系统TIME_WAIT的tcp连接很多：
    shell> netstat -n | awk '/^tcp/ {++state[$NF]} END {for(key in state) print key,"\t",state[key]}'
    TIME_WAIT 250263
    CLOSE_WAIT 57
    FIN_WAIT2 3
    ESTABLISHED 2463
    SYN_RECV 8
    # ss 比 netstat 要快，所以也可以用下面的命令来查看：
    # ss（socket statistics）参数和使用
    ss -ant | awk 'NR>1 {++s[$1]} END {for(k in s) print k,s[k]}'
    # 通过查看/proc/sys/net/ipv4/ip_local_port_range可以知道设置的Linux内核自动分配端口的端口范围：

}
function shutdown() {
    # 在linux中可以用shutdown命令实现自动定时关机的功能，总结如下：
    # 1、shutdown -r now  关机后重启
    # 2、shutdown -h now  关机后不重启
    # 3、shutdown -r +10 10分钟后重启
    # 4、shutdown -r 10:00 10点钟重启
    # 5、shutdown -h +10 10分钟后关机
    # 6、shutdown -h 10:00 10点钟关机
}
function toggleNetwork() {
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

 
# Jenkins Credential 
function installJenkinsCredential() {
   # “Username and password” 凭证 
   # 例如: gitlab-userpwd-pair (访问gitlab所有仓库)
   # “SSH Username with private key” 凭证
   # 例如: gitlab-private-key
   # 在 ID 字段中，必须指定一个有意义的Credential ID- 例如 jenkins-user-for-xyz-artifact-repository。注意: 该字段是可选的
   # 建议使用类似下面的format做为credential ID， 便于jenkinsfile开发时直接使用，同时在”描述“里写清楚credential的作用
   # gitlab-api-token、gitlab-private-key、gitlab-userpwd-pair、harbor-xxx-xxx
   #
   # 
   # 代码仓库凭证，访问gitlab所有仓库
   gitlab-userpwd
   # 镜像仓库凭证，访问swr所有仓库
   hwswr-userpwd 
   hwswr-chinasoft-userpwd
   # 部署服务器凭证，通用访问所有服务器，特殊需要重新命名
   deploy-private-key
   # 某个特殊服务器
   deploy-xx-private-key

}


function checkWall() {
    # 显示状态：
    sudo firewall-cmd --state
    # 查看已经开放的端口
    sudo firewall-cmd --zone=public --list-ports --permanent 
    # 查看已经开放的服务
    sudo firewall-cmd --zone=public --list-services --permanent 
        # 查看区域信息
    sudo firewall-cmd --list-all-zone
    # 查看区域信息
    sudo firewall-cmd --get-active-zones
    # 将接口添加到区域，默认接口都在public ens192
    sudo firewall-cmd --zone=public --add-interface=eth0
    # 永久生效再加上 --permanent(永久生效) 然后reload防火墙
    sudo firewall-cmd --query-port=22/tcp
    sudo firewall-cmd --zone=public --add-port=22/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=80-81/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=8000-8888/tcp --permanent 
    sudo firewall-cmd --zone=public --add-port=53/udp --permanent
    sudo firewall-cmd --zone=public --add-port=2377/tcp --permanent 
    sudo firewall-cmd --zone=public --add-port=18880/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=20880-20882/tcp --permanent  

    sudo firewall-cmd --zone=public --add-port=500/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=4500/tcp --permanent
    # 删除
    sudo firewall-cmd --zone=public --remove-port=27017/tcp --permanent  
    sudo firewall-cmd --zone=public --remove-port=20880-20888/tcp --permanent 


    # firewalld端口转发
    # 开启防火墙伪装：   //开启后才能转发端口
    sudo firewall-cmd --zone=public --add-masquerade --permanent 
    sudo firewall-cmd --zone=public --query-masquerade
    # 查看已经转发的端口
    sudo firewall-cmd --zone=public --list-forward-ports
    # 添加转发规则
    # 将本机80端口转发到192.168.1.1的8080端口上，配置完--reload才生效
    sudo firewall-cmd --zone=public --add-forward-port=port=80:proto=tcp:toport=8080:toaddr=192.168.1.1 --permanent
    # 将本机端口8080的流量，转发至指定ip192.168.22.55，同时继续使用端口8080
    sudo firewall-cmd --zone=public --add-forward-port=port=8080:proto=tcp:toaddr=192.168.22.55 --permanent
    # 将本机端口8882的流量，转发至本机端口22
    sudo firewall-cmd --zone=public --add-forward-port=port=8882:proto=tcp:toport=22 --permanent
    # 将本机端口8882的流量，转发至本机端口22
    sudo firewall-cmd --zone=public --add-forward-port=port=20881:proto=tcp:toport=19094:toaddr=192.168.171.149 --permanent
    sudo firewall-cmd --zone=public --add-forward-port=port=20882:proto=tcp:toport=29094:toaddr=192.168.171.149 --permanent
    sudo firewall-cmd --zone=public --add-forward-port=port=20881:proto=tcp:toport=64021 --permanent
    sudo firewall-cmd --zone=public --add-forward-port=port=20882:proto=tcp:toport=64022 --permanent

    sudo firewall-cmd --zone=public --add-forward-port=port=8883:proto=tcp:toport=8088:toaddr=192.168.22.55 --permanent
    # 移除
    sudo firewall-cmd --zone=public --remove-forward-port=port=8080:proto=tcp:toport=8088:toaddr=192.168.22.55 --permanent

    # 如果配置完以上规则后仍不生效，检查防火墙是否开启80端口，如果80端口已开启，仍无法转发，可能是由于内核参数文件sysctl.conf未配置ip转发功能，具体配置如下：
    sudo vi /etc/sysctl.conf
    # net.core.rmem_default = 33554432
    # net.core.rmem_max = 33554432
    # net.ipv4.ip_forward = 1

    # 在文本内容中添加：net.ipv4.ip_forward = 1
    # 保存文件后，输入命令sudo sysctl -p生效
    # sysctl 命令的 -w 参数可以实时修改Linux的内核参数，并生效
    # sysctl -w net.ipv4.ip_forward=1


    sudo firewall-cmd --zone=public --add-service=docker --permanent 
    # 更新防火墙规则 两者的区别就是第一个无需断开连接，就是firewalld特性之一动态添加规则，第二个需要断开连接，类似重启服务
    sudo firewall-cmd --reload
    sudo firewall-cmd --complete-reload
}
# TODO 未完成，下面是命令行用法
function installEnv() {
    # 更新最新版本 openssh
    sudo yum install openssh -y
    # 检查网卡
    sudo nmcli con show -active
    sudo nmcli con show eth0
    # 检查 防火墙 是 iptable 还是 Firewalls
    sudo systemctl status iptables.service 
    sudo systemctl status firewalld.service
    sudo firewall-cmd --zone=public --list-ports
    ssh -V

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
    # eval "$(ssh-agent -s)"
    ssh-copy-id root@39.100.234.208  
    # 增加主机信任
    # ssh登录到主机
    ssh root@39.100.234.208
    # 跳板登录
    ssh -o "ProxyCommand ssh -p 1098 lmx@proxy.machine nc -w 1 %h %p" -p 1098 lmx@target.machine
    # 设置主机名  项目简称xxx-序号1-ip尾数
    hostnamectl set-hostname xxxapp-1-188
    
    # 首先通过smartctl -H /dev/sda检查磁盘健康状态
    # 然后smartctl -a /dev/sda查看磁盘详细情况，再对磁盘进行短期测试smartctl -t short /dev/sda
    # 最后查看磁盘测试结果smartctl -l selftest /dev/sda
    # 基本磁盘健康状态就可以定位出来，最后检查磁盘错误日志smartctl -l error /dev/sda

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
    #
    cat /etc/sysconfig/network-scripts/ifcfg-eth0
    # 显示当前网络连接
    sudo nmcli con show -active
    sudo nmcli con show eth0
    # 显示设备的连接状态
    sudo nmcli dev status
    sudo nmcli dev show eth0
    # 修改当前网络连接对应的DNS服务器，这里的网络连接可以用名称或者UUID来标识
    sudo nmcli con mod eth0 ipv4.dns "114.114.114.114 8.8.8.8"
    sudo nmcli con mod "Wired connection 3" +ipv4.dns 8.8.8.8
    sudo nmcli con mod eth0 ipv4.addresses 192.168.171.251/24 ipv4.gateway 192.168.171.25
    # 将dns配置生效
    sudo nmcli con up eth0
    # 重新加载配置网络配置文件
    sudo nmcli con reload
    
    # 安装一些通用软件
    sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    sudo yum install -y ngrep htop
    sudo yum install -y openssh wget curl dnsmasq bind-utils net-tools lrzsz rsync zip unzip nc selinux-policy*  yum-utils device-mapper-persistent-data lvm2 iptables-services kernel-devel usbutils pciutils
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
    passwd dev NpSmC2gV   
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
        https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    # step 3: 更新并安装 Docker-CE
    sudo yum makecache fast
    sudo yum list available docker-ce --showduplicates
    # sudo yum install -y docker-ce-18.09.9 docker-ce-cli-18.09.9 containerd.io
    sudo yum install -y docker-ce-3:23.0.6-1.el7.x86_64 docker-ce-cli-3:23.0.6-1.el7 .x86_64 containerd.io
    # sudo yum -y install docker-ce
    # step 4: 开启Docker服务
    sudo service docker start 
    sudo systemctl start docker && sudo systemctl enable docker && sudo systemctl status docker
    # docker执行权限分配 sudo usermod -aG docker your-user
    sudo usermod -aG docker $(whoami)
    # sudo usermod -aG docker dev
    # 重新登录以后测试
    docker -v

    # https://github.com/docker/for-linux/issues/264
    # Support host.docker.internal DNS name to host
    # ip -4 route list match 0/0 | awk '{print $3" host.docker.internal"}'
    # 在容器中设定 docker.host.internal
    echo -e "`/sbin/ip route|awk '/default/ { print $3 }'`\tdocker.host.internal" | sudo tee -a /etc/hosts > /dev/null

}


function installK8s {
# 下载并安装sealos, sealos是个golang的二进制工具，直接下载拷贝到bin目录即可, release页面也可下载
    wget -c https://sealyun.oss-cn-beijing.aliyuncs.com/latest/sealos && \
    chmod +x sealos && mv sealos /usr/bin 

    # 下载离线包
    # kube1.18.13.tar.gz
    curl -jksSL -o kube1.18.13.tar.gz https://sealyun.oss-cn-beijing.aliyuncs.com/e006e2c2f6026d3e9247794a3f026c99-v1.18.13/kube1.18.13.tar.gz
    curl -jksSL -o kube1.18.14.tar.gz https://sealyun.oss-cn-beijing.aliyuncs.com/8243bff8424cab65d673c606dcabc2c7-v1.18.14/kube1.18.14.tar.gz

    # kube1.19.5.tar.gz
    curl -jksSL -o kube1.19.5.tar.gz https://sealyun.oss-cn-beijing.aliyuncs.com/ca41f7b7132bf2ffe5085416ad4b9efd-v1.19.5/kube1.19.5.tar.gz

    # 复制秘钥
    ssh-copy-id -i  ~/.ssh/agent root@192.168.188.188

    # 安装一个三master的kubernetes集群
    sealos init --pk /root/.ssh/agent \
        --master 192.168.188.188  \
        --pkg-url /root/kube1.18.14.tar.gz \
        --version v1.18.14

    # 安装 dashboard
    # https://github.com/sealstore/dashboard/releases/download/v2.0.0-bata5/dashboard.tar
    sealos install --pkg-url dashboard.tar
    # 清理
    sealos clean --all 


    # 增加 KUBECONFIG 到 bash_profile
    echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
    # 生效
    source ~/.bash_profile

    #
    kubectl get namespaces 
    # 查询所有的pod
    kubectl get pods --all-namespaces
    # 查询所有的service
    kubectl get svc --all-namespaces
    # 查看集群状态
    kubectl get nodes -owide

    # 角色问题
    kubectl create clusterrolebinding system:anonymous   --clusterrole=cluster-admin   --user=system:anonymous


    # 获取dash证书
    kubectl get secret -nkubernetes-dashboard $(kubectl get secret -n kubernetes-dashboard|grep dashboard-token |awk '{print $1}') -o jsonpath='{.data.token}'  | base64 --decode
    # dashboard 证书生成
    mkdir key && cd key
    #生成证书
    openssl genrsa -out dashboard.key 2048 
    #我这里写的自己的node1节点，因为我是通过nodeport访问的；如果通过apiserver访问，可以写成自己的master节点ip
    openssl req -new -out dashboard.csr -key dashboard.key -subj '/CN=192.168.188.188'
    openssl x509 -req -in dashboard.csr -signkey dashboard.key -out dashboard.crt 
    #删除原有的证书secret
    kubectl delete secret kubernetes-dashboard-certs -n kubernetes-dashboard
    #创建新的证书secret
    kubectl create secret generic kubernetes-dashboard-certs \
            --from-file=dashboard.key \
            --from-file=dashboard.crt \
            -n kubernetes-dashboard

    #查看pod
    kubectl get pod -n kubernetes-dashboard
    #重启pod
    kubectl delete pod kubernetes-dashboard-7d9ddf9f8f-mvjmx -n kubernetes-dashboard

    # 是因为默认kubernetes默认不让pod部署到master节点，但是我在测试环境只有一个节点也是master节点，需要允许master节点部署pod
    kubectl taint nodes --all node-role.kubernetes.io/master-
    # 如果想要禁止，则执行以下命令
    kubectl taint nodes app-188 node-role.kubernetes.io/master=true:NoSchedule


    # 创建 默认docker帐户 指定命名空间
    kubectl --namespace base-app \
        create secret docker-registry huawei-swr \
        --docker-server=swr.cn-north-4.myhuaweicloud.com \
        --docker-username=cn-north-4@QDEHGTFHJIEC6G8XMZ7R \
        --docker-password=a943981a098e75225c345eb7775fc49997cf2cbb7310bc42af421e8d9bd4b7e1 
    # 执行默认
    kubectl -n base-app patch serviceaccount default -p '{"imagePullSecrets": [{"name": "huawei-swr"}]}'

    
    # kubectl exec 执行 容器命令
    kubectl exec -it podName  -c  containerName -n namespace -- shell comand
    kubectl exec -it devops-jenkins-5485cbdc4b-mcw94 -c container-1 -n default -- date

    kubectl cp caches/gradle-6.7.1-bin.zip  devops-jenkins-5485cbdc4b-mcw94:/tmp/

    kubectl exec -it devops-jenkins-5485cbdc4b-mcw94 -c container-1 -n default -- /bin/bash

}

function installNfs() {
    # 增加nfs用户
    useradd nfs
    mkdir /home/nfs/data
    chown -R nfs:nfs /home/nfs/data
    chmod 777 -R /home/nfs/data

    # 安装
    sudo yum install nfs-utils
    # 开启
    sudo systemctl enable rpcbind 
    sudo systemctl enable nfs
    sudo systemctl start rpcbind 
    sudo systemctl start nfs 
    # 防火墙需要打开 rpc-bind 和 nfs 的服务
    sudo firewall-cmd --zone=public --permanent --add-service={rpc-bind,mountd,nfs}
    sudo firewall-cmd --reload
    # 根据目录，相应配置导出目录
    # 添加如下配置
    # 受限 192.168.188.0/24 网段
    echo "/home/nfs/data     192.168.188.0/24(rw,sync,no_root_squash,no_all_squash,anonuid=0,anongid=0)" >> /etc/exports
    # 不受限 
    echo "/home/nfs/data     *(rw,sync,no_root_squash,no_all_squash,anonuid=0,anongid=0)" >> /etc/exports
    # 重启服务
    sudo systemctl restart nfs
    # nfs v3
    mount -t nfs -o vers=3 192.168.188.188:/home/nfs/data /data
    # nfs v4
    mount -t nfs -o vers=4 192.168.188.188:/home/nfs/data /data
    # 检查一下本地的共享目录
    showmount -e localhost
    # 取消本地
    umount  /data

    # Linux nfs客户端对于同时发起的NFS请求数量进行了控制，若该参数配置较小会导致IO性能较差，请查看该参数：
    cat /proc/sys/sunrpc/tcp_slot_table_entries
    # 默认编译的内核该参数最大值为256，可适当提高该参数的值来取得较好的性能，请以root身份执行以下命令：
    echo "options sunrpc tcp_slot_table_entries=128" >> /etc/modprobe.d/sunrpc.conf
    echo "options sunrpc tcp_max_slot_table_entries=128" >>  /etc/modprobe.d/sunrpc.conf
    sysctl -w sunrpc.tcp_slot_table_entries=128
    # 修改完成后，您需要重新挂载文件系统或重启机器。


    # FIO进行吞吐和IOPS的性能测试。
    # 性能测试前，请注意以下事项
    # 1 确认sunrpc_slot设置正确，详情请参见linux上NFS性能只有几MB速度。
    # 2 吞吐最大不会超过ECS带宽。如果您的ECS带宽只有1Gbps，则吞吐最大可达到125 MB/s。
    # 3 fio测试工具应该已经在您的ECS上预安装了，若您发现fio没有正常安装，可通过以下命令进行安装。
    sudo yum install fio
    # sudo apt-get install fio
    # 随机读IOPS设置 单机预估值：14k
    fio -numjobs=1 -iodepth=128 -direct=1 -ioengine=libaio -sync=1 -rw=randread -bs=4K -size=1G -time_based -runtime=60 -name=Fio -directory=/mnt
    # 随机写IOPS设置 单机预估值：10k
    fio -numjobs=1 -iodepth=128 -direct=1 -ioengine=libaio -sync=1 -rw=randwrite -bs=4K -size=1G -time_based -runtime=60 -name=Fio -directory=/mnt
    # 随机读吞吐 容量型单机预估值：150 MB/s 性能型单机预估值：300 MB/s
    fio -numjobs=1 -iodepth=128 -direct=1 -ioengine=libaio -sync=1 -rw=randread -bs=1M -size=1G -time_based -runtime=60 -name=Fio -directory=/mnt
    # 随机写吞吐 容量型单机预估值：150 MB/s 性能型单机预估值：300 MB/s
    fio -numjobs=1 -iodepth=128 -direct=1 -ioengine=libaio -sync=1 -rw=randwrite -bs=1M -size=1G -time_based -runtime=60 -name=Fio -directory=/mnt

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
    https://github.com/docker/compose/releases/download/1.24.1/docker-compose-Linux-x86_64
    # step 1: 方式一 下载最新版本的 docker-compose 到 /usr/bin 目录下
    sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
    # step 1: 方式二 本地上传
    scp -r  -P 18022 ~/Downloads/docker-compose-Linux-x86_64 root@58.49.165.253:/usr/bin/docker-compose
    scp -r  -P 22 ~/Downloads/docker-compose-Linux-x86_64 root@119.3.160.6:/usr/bin/docker-compose
    scp -r  -P 8882 ~/Downloads/docker-compose-Linux-x86_64 root@221.234.48.146:/usr/bin/docker-compose
    # step 2: 增加执行权限
    sudo ls -al /usr/bin/docker-compose && sudo chmod +x /usr/bin/docker-compose
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
    docker pull g127/ps:20210204-buster
    # redis 老版本 redis:3.0.7-alpine 新版本 redis:3.2.12-alpine  redis:5.0-alpine
    docker pull redis:5.0-alpine
    # mysql 5.7 
    docker pull g127/mysql:5.7

    # 如果网络不好，使用save 和 load
    sudo docker save -o g127-java.tar  g127/java

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
    # 
    docker image inspect --format='{{.RepoTags}} {{.Id}} {{.Parent}}' $(docker image ls -q --filter since=963db9e8c767)

    # 执行【初始化目录】
    docker run -it --rm -e SWITCH_RUN=init -v ~/DevProjectFiles:/DevProjectFiles g127/ps:20210204-buster bash
    # 修改【初始化目录】属主
    chown dev:dev -R ~/DevProjectFiles
    # 查询 docker容器中运行 相关命令 查询 jdk版本和tomcat版本
    docker run -it --rm -e SWITCH_RUN=bash g127/ps:20210204-buster catalina.sh version
    # 查询 nginx 版本
    docker run -it --rm -e SWITCH_RUN=bash g127/ps:20210204-buster nginx -V 
    # 查询 geo文件
    docker run -it --rm -e SWITCH_RUN=bash g127/ps:20210204-buster ls -l /usr/local/share/GeoIP/
    # redis
    docker run -it --rm redis:5.0-alpine ls -l /usr/local/etc/redis/
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

