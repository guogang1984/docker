

docker run \
  --hostname mysql \
  --name mysql \
  --restart=unless-stopped  \
  -e MYSQL_ROOT_PASSWORD='root' \
  -p 3306:3306 \
  -v ~/DevProjectFiles/ws-data/mysql:/var/lib/mysql \
  --privileged \
  -d g127/mysql