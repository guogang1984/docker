docker pull sonarqube:8.3-community
docker pull sonarqube:7.7-community


### mysql
DROP USER sonar, sonar@localhost;
DROP DATABASE sonar IF EXISTS;
CREATE DATABASE sonar CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
create user sonar identified by 'sonar';
grant all privileges on sonar.* to 'sonar'@'localhost' identified by 'sonar' with grant option;
grant all privileges on jiradb.* to 'sonar'@'%' identified by 'sonar' with grant option;
flush privileges;

### postgres
create user sonar with password 'sonar';
create database sonar owner sonar; 
grant all on database sonar to sonar;

### sonarqube mysql 注意 sonarqube7.9后不再支持mysql，建议换成Postgresql
docker run \
 --name sonarqube \
 -p 9082:9000 \
 --restart=unless-stopped \
 --link=mysql:mysql \
 -e SONARQUBE_JDBC_USERNAME=sonar \
 -e SONARQUBE_JDBC_PASSWORD=sonar \
 -e SONARQUBE_JDBC_URL="jdbc:mysql://mysql:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance&useSSL=false" \
 -v $HOME/DevProjectFiles/ws-data/sonarqube/.data:/opt/sonarqube/data \
 -v $HOME/DevProjectFiles/ws-data/sonarqube/.extensions:/opt/sonarqube/extensions \
 -v $HOME/DevProjectFiles/ws-data/sonarqube/.logs:/opt/sonarqube/logs \
 -v $HOME/DevProjectFiles/ws-data/sonarqube/.temp:/opt/sonarqube/temp \
 -d  sonarqube:7.7-community

### sonarqube postgres
docker run \
 --name sonar \
 -p 9000:9000 \
 --restart=unless-stopped \
 --link=postgres:postgres \
 -e SONARQUBE_JDBC_USERNAME=sonar \
 -e SONARQUBE_JDBC_PASSWORD=sonar \
 -e SONARQUBE_JDBC_URL=jdbc:postgresql://postgres:5432/sonar \
 -v $HOME/DevProjectFiles/ws-data/sonarqube/.data:/opt/sonarqube/data \
 -v $HOME/DevProjectFiles/ws-data/sonarqube/.extensions:/opt/sonarqube/extensions \
 -v $HOME/DevProjectFiles/ws-data/sonarqube/.logs:/opt/sonarqube/logs \
 -v $HOME/DevProjectFiles/ws-data/sonarqube/.temp:/opt/sonarqube/temp \
 -d sonarqube:8.3-community

# https://github.com/SonarSource/docker-sonarqube



# 默认账户 admin admin



# 插件相关 https://blog.csdn.net/u012689060/article/details/83000362