# docker

# git导出干净的代码
# 导出默认路径 可以是当前路径 ./docker-output.zip
rm -rf /Users/gg/Downloads/docker-output.zip

git archive --format zip --output "/Users/gg/Downloads/docker-output.zip" master -0 

scp -r /Users/gg/Downloads/docker-output.zip dev@120.77.218.7:/home/dev/

/Users/gg/DevProjectFiles/ws-my-github/docker

manly
ssh -NfL 13306:127.0.0.1:3306 dev@120.77.218.7


mysql 5.6  --5.7

docker exec -it be0cc52395be mysql_upgrade -uroot -p


scp -r ~/DevProjectFiles/ws-my-github/docker/DevProjectFiles/ws-docker dev@120.77.218.7:/home/dev/DevProjectFiles/

scp -r ~/DevProjectFiles/ws-my-github/docker/DevProjectFiles/ws-bin dev@120.77.218.7:/home/dev/DevProjectFiles/

scp -r ~/DevProjectFiles/ws-my-github/docker/DevProjectFiles/ws-conf/nginx/vhosts/projects dev@120.77.218.7:/home/dev/DevProjectFiles/ws-conf/nginx/vhosts/


scp -r ~/DevProjectFiles/ws-my-github/docker/DevProjectFiles/ws-conf/nginx/ dev@120.77.218.7:/home/dev/DevProjectFiles/ws-conf/nginx/upstream.conf





# 机器配置
机子内存如果是 4G：
 
CATALINA_OPTS="-Dfile.encoding=UTF-8 -server -Xms2048m -Xmx2048m -Xmn1024m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:SurvivorRatio=10 -XX:MaxTenuringThreshold=15 -XX:NewRatio=2 -XX:+DisableExplicitGC"
 
机子内存如果是 8G：
 
CATALINA_OPTS="-Dfile.encoding=UTF-8 -server -Xms4096m -Xmx4096m -Xmn2048m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:SurvivorRatio=10 -XX:MaxTenuringThreshold=15 -XX:NewRatio=2 -XX:+DisableExplicitGC"
 
机子内存如果是 16G：
 
CATALINA_OPTS="-Dfile.encoding=UTF-8 -server -Xms8192m -Xmx8192m -Xmn4096m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:SurvivorRatio=10 -XX:MaxTenuringThreshold=15 -XX:NewRatio=2 -XX:+DisableExplicitGC"
 
机子内存如果是 32G：
 
CATALINA_OPTS="-Dfile.encoding=UTF-8 -server -Xms16384m -Xmx16384m -Xmn8192m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:SurvivorRatio=10 -XX:MaxTenuringThreshold=15 -XX:NewRatio=2 -XX:+DisableExplicitGC"
 
如果是 8G 开发机
 
-Xms2048m -Xmx2048m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:PermSize=256m -XX:MaxPermSize=512m
 
如果是 16G 开发机
 
-Xms4096m -Xmx4096m -XX:NewSize=1024m -XX:MaxNewSize=2048m -XX:PermSize=256m -XX:MaxPermSize=512m


-XX:PermSize和-XX:MaxPermSize在jdk1.8中被弃用了，使用-XX:MetaspaceSize和-XX:MaxMetaspaceSize替代。
所以此时VM参数正确应为：–XX:MetaspaceSize=512m -XX:MaxMetaspaceSize=1024m

