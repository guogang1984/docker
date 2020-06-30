server {
    listen    80;
#   listen    443 ssl;
    server_name %WWW_APP_COM%;

    # root
    set    $www_domain          %WWW_APP_COM%;

    #ssl_certificate           vhosts/cert/${www_domain}.cer;
    #ssl_certificate_key       vhosts/cert/${www_domain}.key;

    #if ( $host != $www_domain  ) {
    #    rewrite ^/(.*) http://$www_domain/$1 permanent;
    #}

    include vhosts/vhost-common.conf;

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    
    # ================================================================
    # application target:%TARGET_NAME% service:%APP_SERVICE%
    # ================================================================
    location /prod-api/ {
        include            vhosts/proxy.set.header.common.conf;
        proxy_cookie_path  /%APP_SERVICE%/ /;
        proxy_cookie_path  /%APP_SERVICE%  /;

        set $service       '%APP_SERVICE%';
        set $target        '%TARGET_NAME%'; # cluster-tomcat, cluster-dev-tomcat
        proxy_pass         http://$target/$service/;
        # rewrite
        rewrite "^/prod-api/(.*)$" /$service/$1 break;
    }
    
    location /%APP_SERVICE%/ {
        #allow 221.232.0.0/16;
        #deny all;
        sub_filter         /topflames-oa/   '/%APP_SERVICE%/';
        sub_filter_once    off;
        #sub_filter_types  text/html;

        include            vhosts/proxy.set.header.common.conf;
        proxy_cookie_path  /%APP_SERVICE%/ /;
        proxy_cookie_path  /%APP_SERVICE%  /;

        set $service       '%APP_SERVICE%';
        set $target        '%TARGET_NAME%'; # cluster-tomcat, cluster-dev-tomcat
        proxy_pass         http://$target/$service/;
        # rewrite
        rewrite "^/%APP_SERVICE%/(.*)$" /$service/$1 break;
    }
 
    location ~* ^/%APP_SERVICE%/(^storage/rest/p/avatar/user)/(.*)\.(cab|css|js|ico|gif|bmp|jpg|jpeg|png|swf|mp3)$ {
        #default_type 'text/plain'; 
        #echo "node";
        #echo The current request uri is $request_uri;
        access_log  off;
 
        proxy_cache cache_one;
        proxy_cache_valid 200 304 301 302 10d;
        proxy_cache_valid any 1m;
        proxy_cache_key $host$uri$is_args$args;
        proxy_pass      http://cluster-dev-tomcat$request_uri;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
 
    # default news path 
    location /%APP_SERVICE%/noticeHtml/ {
        sub_filter      /topflames-oa/   '/%APP_SERVICE%/';
        sub_filter_once off;
        sub_filter_types *;
        alias /DevProjectFiles/ws-root/fileResources/notice/; 
    }
}
