FROM sonarqube:7.9-community

# Copy Plugins
COPY --chown=sonarqube:sonarqube plugins/ /opt/sonarqube/extensions/plugins/

ENV SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=jdbc:postgresql://postgres:5432/sonar 


RUN echo 'run script' \
    # rm old version
    && rm -rf /opt/sonarqube/extensions/plugins/sonar-java-plugin-5*.jar \
    && ls -al /opt/sonarqube/extensions/plugins/

# # java-plugin
# curl -jksSL -o \
#     plugins/sonar-java-plugin-6.9.0.23563.jar \
#     https://binaries.sonarsource.com/Distribution/sonar-java-plugin/sonar-java-plugin-6.9.0.23563.jar
# 
# # checkstyle
# curl -jksSL -o \
#     plugins/checkstyle-sonar-plugin-8.37.jar \
#     https://github.com/checkstyle/sonar-checkstyle/releases/download/8.37/checkstyle-sonar-plugin-8.37.jar 
# 
# # sonar-pmd
# curl -jksSL -o \
#     plugins/sonar-pmd-plugin-3.2.1.jar \
#     https://github.com/jensgerdes/sonar-pmd/releases/download/3.2.1/sonar-pmd-plugin-3.2.1.jar
# 
# # sonar-findbugs
# curl -jksSL -o \
#     plugins/sonar-findbugs-plugin-3.3\
#     https://binaries.sonarsource.com/Distribution/sonar-findbugs-plugin/sonar-findbugs-plugin-3.3.jar



# 构建
# docker build -f Dockerfile -t g127/sonarqube:7.9-community .
# docker tag g127/sonarqube:7.9-community swr.cn-north-4.myhuaweicloud.com/topflames_paas/sonarqube:7.9-community
# docker push swr.cn-north-4.myhuaweicloud.com/topflames_paas/sonarqube:7.9-community
# docker run \
#  --name sonar \
#  -p 9000:9000 \
#  --restart=unless-stopped \
#  --link=postgres:postgres \
#  -v $HOME/DevProjectFiles/ws-data/sonarqube/.data:/opt/sonarqube/data \
#  -v $HOME/DevProjectFiles/ws-data/sonarqube/.logs:/opt/sonarqube/logs \
#  -v $HOME/DevProjectFiles/ws-data/sonarqube/.temp:/opt/sonarqube/temp \
#  -d swr.cn-north-4.myhuaweicloud.com/topflames_paas/sonarqube:7.9-community