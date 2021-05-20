#!/bin/bash -e

function installCrond(){

    crontab -l | { cat; echo "30 22 * * * /usr/bin/rsync --no-iconv -avzP --progress --delete --password-file=/etc/rsync.downloadUser.pas rsync://downloadUser@59.111.89.18:873/release/ /home/dev/DevProjectFiles/ws-release"; } | crontab -  \

    crontab -l | { cat; echo "30 1 * * * /usr/bin/rsync --no-iconv -avzP --progress --delete --password-file=/etc/rsync.downloadUser.pas rsync://downloadUser@59.111.89.18:873/root/ /home/dev/DevProjectFiles/ws-root"; } | crontab -  \

    echo -e ' ===> create file '  \
    &&  { \
            echo '[program: crond]'; \
            echo 'command=cron -f'; \
            echo 'autostart=true'; \
            echo 'autorestart=true'; \
            echo 'killasgroup=true'; \
            echo 'stopasgroup=true'; \
            echo 'startretries=5'; \
            echo 'numprocs=1'; \
            echo 'startsecs=0'; \
            echo 'process_name=%(program_name)s_%(process_num)02d'; \
            echo ''; \
        } | tee /etc/supervisord.d/cron.ini \


}
