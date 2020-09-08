    # %SVC%_backend
    upstream stream.%SVC%.server {
        hash $remote_addr consistent;
        server %SVC_URL% weight=5 max_fails=3 fail_timeout=60s;
    }

    server {
        listen %SVC_SVR_PORT%;
        proxy_connect_timeout 3s;
        proxy_timeout 10s;
        proxy_pass stream.%SVC%.server;
        #proxy_bind $remote_addr transparent;
    }
