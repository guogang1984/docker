    upstream mysql_backend {
        hash $remote_addr consistent;
        #server 127.0.0.1:3306 weight=5 max_fails=3 fail_timeout=30s;
        server 127.0.0.1:3306 weight=5;
    }
    
    server {
        listen %HOSTIP%:3306;
        #proxy_connect_timeout 1s;
        #proxy_timeout 3s;
        proxy_pass mysql_backend;
        #proxy_bind $remote_addr transparent;
    }π