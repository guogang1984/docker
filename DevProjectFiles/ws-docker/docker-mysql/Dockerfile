ARG G127_IMAGE_BASE="mysql"
ARG G127_IMAGE_TAG="5.7"

FROM ${G127_IMAGE_BASE}:${G127_IMAGE_TAG}

ARG G127_IMAGE_TAG="5.7"

ENV MYSQL_ROOT_PASSWORD='root'

RUN echo ${G127_IMAGE_TAG}

# 拷贝配置
COPY conf/${G127_IMAGE_TAG}/my.cnf /etc/mysql/conf.d/

# 拷贝目录
COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/


# docker build --build-arg G127_IMAGE_TAG=5.7 -f Dockerfile -t g127/mysql:5.7 .
# docker run -it --rm -e MYSQL_ROOT_PASSWORD=root -p 33306:3306 g127/mysql:5.7

# docker build --build-arg G127_IMAGE_TAG=8.0 -f Dockerfile  -t g127/mysql:8.0 .
#
# ( docker rm -fv db-mysql8 || /bin/true ) && docker run -it \
#   --name db-mysql8 \
#   -e MYSQL_ROOT_PASSWORD=root \
#   -v `pwd`/conf/8.0/my.cnf:/etc/mysql/conf.d/my.cnf \
#   -v `pwd`/MySQL80-3306:/var/lib/mysql/ \
#   -p 33306:3306  \
#   -d g127/mysql:8.0
#


#  docker run \
#    --hostname db-mysql  \
#    --name db-mysql  \
#    --restart=unless-stopped   \
#    -e MYSQL_ROOT_PASSWORD='root'  \
#    -p 3308:3306  \
#    -v ~/DevProjectFiles/ws-conf/alpine/etc/localtime:/etc/localtime:ro  \
#    -v ~/DevProjectFiles/ws-data/mysql:/var/lib/mysql   \
#    -v ~/DevProjectFiles/ws-back:/DevProjectFiles/ws-back  \
#    --privileged  \
#    --net=app-net  \
#    -d g127/mysql:5.7
#
#  docker run \
#    --hostname db-mysql8  \
#    --name db-mysql8  \
#    --restart=unless-stopped   \
#    -e MYSQL_ROOT_PASSWORD='root'  \
#    -p 3308:3306  \
#    -v ~/DevProjectFiles/ws-conf/alpine/etc/localtime:/etc/localtime:ro  \
#    -v ~/DevProjectFiles/ws-data/mysql:/var/lib/mysql80   \
#    -v ~/DevProjectFiles/ws-back:/DevProjectFiles/ws-back  \
#    --privileged  \
#    --net=app-net  \
#    -d g127/mysql:8.0

# docker run -it \
#   --restart=unless-stopped  \
#   --name db-mysql8 \
#   -e MYSQL_ROOT_PASSWORD=root \
#   -v D:/DevProgram/upupw/MySQL80-3306:/var/lib/mysql/ \
#   -p 3306:3306  \
#   --privileged \
#   --net=app-net \
#   -d g127/mysql:8.0