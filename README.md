# docker

# git导出干净的代码
# 导出默认路径 可以是当前路径 ./docker-output.zip
rm -rf /Users/gg/Downloads/docker-output.zip

git archive --format zip --output "/Users/gg/Downloads/docker-output.zip" master -0 

/Users/gg/DevProjectFiles/ws-my-github/docker

manly
ssh -NfL 13306:127.0.0.1:3306 dev@120.77.218.7


mysql 5.6  --5.7

docker exec -it be0cc52395be mysql_upgrade -uroot -p


scp -r ~/DevProjectFiles/ws-my-github/docker/DevProjectFiles/ws-docker dev@120.77.218.7:/home/dev/DevProjectFiles/

scp -r ~/DevProjectFiles/ws-my-github/docker/DevProjectFiles/ws-bin dev@120.77.218.7:/home/dev/DevProjectFiles/

scp -r ~/DevProjectFiles/ws-my-github/docker/DevProjectFiles/ws-conf/nginx/vhosts/projects dev@120.77.218.7:/home/dev/DevProjectFiles/ws-conf/nginx/vhosts/


scp -r ~/DevProjectFiles/ws-my-github/docker/DevProjectFiles/ws-conf/nginx/ dev@120.77.218.7:/home/dev/DevProjectFiles/ws-conf/nginx/upstream.conf
