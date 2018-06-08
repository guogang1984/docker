    upstream redis3_backend {
        hash $remote_addr consistent;
        server 127.0.0.1:6389 weight=5 max_fails=3 fail_timeout=30s;
    }
    
    server {
        listen %HOSTIP%:6389;
        proxy_connect_timeout 1s;
        proxy_timeout 3s;
        proxy_pass redis3_backend;
        #proxy_bind $remote_addr transparent;
    }