#!/bin/bash

# h.sh  ->  helper.sh
# centos7 docker app script
# Nexus3.x批量导入本地库
# docker pull sonatype/nexus3:3.22.0
# docker run -p 8081:8081 -it --name nexus3 -v ~/DevProjectFiles/ws-data/nexus3-data:/nexus-data sonatype/nexus3:3.22.0
# docker run -p 8081:8081 -it --rm --name nexus3 -v ~/DevProjectFiles/ws-data/nexus3-data:/nexus-data sonatype/nexus3:3.22.0
# 查询
# curl -u admin:admin123 -X GET 'http://localhost:8081/service/rest/v1/repositories'
# curl -X GET 'http://localhost:8081/service/rest/v1/repositories'

# TODO 未完成，下面是命令行用法
function installEnv() {
   curl  -X POST -v -u admin:admin123 --header "Content-Type: application/json" 'http://localhost:8081/service/rest/v1/script/' -d @maven.json

   curl -X POST -u admin:admin123 --header "Content-Type: text/plain" http://localhost:8081/service/rest/v1/script/createRepo/run
   {
     "name": "maven",
     "type": "groovy",
     "content": "repository.createMavenHosted('maven-internal')"
   }
}
