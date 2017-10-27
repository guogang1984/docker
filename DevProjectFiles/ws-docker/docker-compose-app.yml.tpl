# --------------------------------------------------------
# Generating docker compose file at %STAMP%
# APP_CONTAINER_NAME=%APP_CONTAINER_NAME%, APP_PORTS=%APP_PORTS%, APP_NETWORKS=%APP_NETWORKS%
# APP_JAR_NAME=%APP_JAR_NAME%
# --------------------------------------------------------
version: "2"
services:
  dac:
    image: 'registry.cn-shenzhen.aliyuncs.com/topflames/java:jdk8tomcat7'
    container_name: %APP_CONTAINER_NAME%
    restart: unless-stopped
    environment:
      TZ: 'Asia/Shanghai'
    ports:
      - '%APP_PORTS%'
    external_links:
        - db-mysql:mysql
        - db-redis3:redis3
    volumes:
      - ~/DevProjectFiles/ws-root/%APP_CONTAINER_NAME%:/DevProjectFiles/ws-root/%APP_CONTAINER_NAME%
      - ~/tmp/logs/%APP_CONTAINER_NAME%:/tmp/logs
      # dac
      - ~/tmp/logs/dac:/tmp/logs
    command: [  "java", "-Djava.security.egd=file:/dev/./urandom", "-Duser.timezone=GMT+08", "-jar","/DevProjectFiles/ws-root/%APP_CONTAINER_NAME%/%APP_JAR_NAME%", "--spring.profiles.active=dev", "--spring.config.location=/DevProjectFiles/ws-root/%APP_CONTAINER_NAME%/application.properties"  ]
    networks:
      - %APP_NETWORKS%
networks:
  %APP_NETWORKS%:
    external:
      name: %APP_NETWORKS%
