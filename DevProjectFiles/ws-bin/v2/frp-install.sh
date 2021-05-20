#!/bin/bash -e


function installSystemdFrp() {
    echo -e ' ===> Runing scripts ' \
    &&  { \
            FRP_VERSION=0.34.3 ; \
            FRP_DOWNLOAD_URL=https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz ;\
            [ ! -f /tmp/frp_${FRP_VERSION}_linux_amd64.tar.gz -a ! -f /tmp/frp_${FRP_VERSION}_linux_amd64.tar ] && wget -q -O /tmp/frp_${FRP_VERSION}_linux_amd64.tar.gz ${FRP_DOWNLOAD_URL} ; \
            [ ! -f /tmp/frp_${FRP_VERSION}_linux_amd64.tar ] && gunzip /tmp/frp_${FRP_VERSION}_linux_amd64.tar.gz; \
            rm -rf /usr/local/frp_${FRP_VERSION}_linux_amd64 /usr/local/frp;
            tar -C /usr/local -xf /tmp/frp_${FRP_VERSION}_linux_amd64.tar; \
            [ -d /usr/local/frp_${FRP_VERSION}_linux_amd64 ] && mv -f /usr/local/frp_${FRP_VERSION}_linux_amd64 /usr/local/frp; \
        } \
    && FRP_TOKEN=rHShi6Z6 \
    && FRP_CLIENT_IP_NAME=188 \
    &&  echo -e ' ===> create file '  \
    &&  { \
            echo '[common]'; \
            echo 'log_level = info'; \
            echo 'log_max_days = 3 '; \
            echo ''; \
            echo 'server_addr = www.topflames.com'; \
            echo 'server_port = 8999'; \
            echo ''; \
            echo 'authenticate_heartbeats = true'; \
            echo 'authenticate_new_work_conns = true'; \
            echo 'authentication_method = token'; \
            echo 'token='${FRP_TOKEN}; \
            echo ''; \
            echo '['${FRP_CLIENT_IP_NAME}'-http]'; \
            echo 'type = tcp'; \
            echo 'local_ip = 127.0.0.1'; \
            echo 'local_port = 80'; \
            echo 'remote_port = ' ${FRP_CLIENT_IP_NAME}'80'; \
            echo ''; \
            echo '['${FRP_CLIENT_IP_NAME}'-https]'; \
            echo 'type = tcp'; \
            echo 'local_ip = 127.0.0.1'; \
            echo 'local_port = 443'; \
            echo 'remote_port = '${FRP_CLIENT_IP_NAME}'43'; \
            echo ''; \
            echo '['${FRP_CLIENT_IP_NAME}'-ssh]'; \
            echo 'type = tcp'; \
            echo 'local_ip = 127.0.0.1'; \
            echo 'local_port = 22'; \
            echo 'remote_port = '${FRP_CLIENT_IP_NAME}'22'; \
            echo ''; \
        } | tee /usr/local/frp/frpc.ini \
    &&  echo -e ' ===> create file '  \
    &&  { \
            echo '[common]'; \
            echo 'log_level = info'; \
            echo 'log_max_days = 3 '; \
            echo ''; \
            echo 'bind_addr = 0.0.0.0'; \
            echo 'bind_port = 8999'; \
            echo ''; \
            echo 'bind_udp_port = 8991'; \
            echo 'kcp_bind_port = 8999'; \
            echo ''; \
            echo '#vhost_http_port = 80'; \
            echo '#vhost_https_port = 443'; \
            echo ''; \
            echo 'dashboard_addr = 0.0.0.0'; \
            echo 'dashboard_port = 7500'; \
            echo 'dashboard_user = admin'; \
            echo 'dashboard_pwd = rHShi6Z6'; \
            echo ''; \
            echo 'token='${FRP_TOKEN}; \
            echo ''; \
            echo 'max_pool_count = 5'; \
            echo 'max_ports_per_client = 0'; \
            echo 'authentication_timeout = 900'; \
            echo 'tcp_mux = true'; \
            echo ''; \
        } | tee /usr/local/frp/frps.ini \
    &&  chmod -R 755 /usr/local/frp \

}


function configureSupervisor() {
    # 如果是centos7 默认配置
    # /opt/supervisor/ 改为  /etc/supervisord.d/
    echo -e ' ===> create file '  \
    &&  { \
            echo '[program: frpc]'; \
            echo "command=/usr/local/frp/frpc -c /usr/local/frp/frpc.ini"; \
            echo 'autorestart=true'; \
            echo 'autostart=true'; \
            echo 'killasgroup=true'; \
            echo 'stopasgroup=true'; \
            echo 'startretries=5'; \
            echo 'numprocs=1'; \
            echo 'startsecs=0'; \
            echo 'process_name=%(program_name)s_%(process_num)02d'; \
            echo ''; \
        } | tee /opt/supervisor/frpc.ini \


    echo -e ' ===> create file '  \
    &&  { \
            echo '[program: frps]'; \
            echo "command=/usr/local/frp/frps -c /usr/local/frp/frps.ini"; \
            echo 'autorestart=true'; \
            echo 'autostart=true'; \
            echo 'killasgroup=true'; \
            echo 'stopasgroup=true'; \
            echo 'startretries=5'; \
            echo 'numprocs=1'; \
            echo 'startsecs=0'; \
            echo 'process_name=%(program_name)s_%(process_num)02d'; \
            echo ''; \
        } | tee /etc/supervisord.d/frps.ini \


# supervisorctl reread （读取新添加的配置让supervisor服务知道）
# supervisorctl update （新添加的配置正式在supervisor中生效）
# supervisorctl start xxx

}

function configureCentos7() {
    echo -e ' ===> create file '  \
    &&  { \
            echo '[Unit]'; \
            echo 'Description=The frp client'; \
            echo 'After=network.target remote-fs.target nss-lookup.target'; \
            echo ''; \
            echo '[Service]'; \
            echo 'Type=simple'; \
            echo 'ExecStart=/usr/local/frp/frpc -c /usr/local/frp/frpc.ini'; \
            echo 'KillSignal=SIGQUIT'; \
            echo 'TimeoutStopSec=5'; \
            echo 'KillMode=process'; \
            echo 'PrivateTmp=true'; \
            echo 'StandardOutput=syslog'; \
            echo 'StandardError=inherit'; \
            echo 'SyslogIdentifier=frpc'; \
            echo ''; \
            echo '[Install]'; \
            echo 'WantedBy=multi-user.target'; \
        } | tee /usr/lib/systemd/system/frpc.service \
    &&  echo -e ' ===> create file '  \
    &&  { \
            echo '[Unit]'; \
            echo 'Description=The frp service'; \
            echo 'After=network.target remote-fs.target nss-lookup.target'; \
            echo ''; \
            echo '[Service]'; \
            echo 'Type=simple'; \
            echo 'ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.ini'; \
            echo 'KillSignal=SIGQUIT'; \
            echo 'TimeoutStopSec=5'; \
            echo 'KillMode=process'; \
            echo 'PrivateTmp=true'; \
            echo 'StandardOutput=syslog'; \
            echo 'StandardError=inherit'; \
            echo 'SyslogIdentifier=frps'; \
            echo ''; \
            echo '[Install]'; \
            echo 'WantedBy=multi-user.target'; \
        } | tee /usr/lib/systemd/system/frps.service \

}

function runSystemdFrpc() {
    systemctl enable frpc
    systemctl start frpc
    systemctl status frpc

    systemctl disable frpc.service
    rm -rf /usr/lib/systemd/system/frpc.service
}

function runSystemdFrps() {
    systemctl enable frps
    systemctl start frps
    systemctl status frps

    systemctl disable frps.service
    rm -rf /usr/lib/systemd/system/frps.service
}


function main() {
    installSystemdFrp
}


main "$@"
