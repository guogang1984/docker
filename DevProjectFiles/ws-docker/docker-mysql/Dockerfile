FROM mysql:5.7

ENV MYSQL_ROOT_PASSWORD='root'

COPY my.cnf /etc/mysql/conf.d/
COPY init-dbuser-dev.sql /docker-entrypoint-initdb.d/
