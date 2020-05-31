# FROM cptactionhank/atlassian-jira-software:7.12.0

# haxqer/jira:rm-8.7.1
FROM haxqer/jira:rm

USER root

# 将代理破解包加入容器
COPY atlassian-agent.jar /opt/atlassian/jira/atlassian-agent.jar

# 设置启动加载代理包
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/jira/atlassian-agent.jar ${CATALINA_OPTS}"' >> $JIRA_INSTALL/bin/setenv.sh


# java -jar atlassian-agent.jar -d -m test@test.com -n BAT -p jira -o http://119.3.184.192:9083 -s BH2M-X79I-M3GM-ULJC


# java -jar atlassian-agent-jar-with-dependencies.jar -d -m test@test.com -n BAT -p jira -o http://119.3.184.192:9083 -s BH2M-X79I-M3GM-ULJC 