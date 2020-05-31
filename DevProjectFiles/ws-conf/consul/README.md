
### consul

#### 开发模式
consul agent -dev
#### 注册服务
curl --request PUT --data @web8080.json http://localhost:8500/v1/agent/service/register?replace-existing-checks=true

{
    "ID":"web8080",
    "Name":"web",
    "Tags":[],
    "Address":"127.0.0.1",
    "Port":8080,
    "EnableTagOverride":false
}

{
    "ID":"web18081",
    "Name":"web",
    "Tags":[],
    "Address":"127.0.0.1",
    "Port":18081,
    "EnableTagOverride":false
}

{
    "ID":"web18082",
    "Name":"web",
    "Tags":[],
    "Address":"127.0.0.1",
    "Port":18082,
    "EnableTagOverride":false
}

####
http://127.0.0.1:8500/v1/catalog/register

#### 查看
curl -X GET http://127.0.0.1:8500/v1/catalog/service/tomcat


curl -X PUT http://127.0.0.1:8500/v1/catalog/register -d '{"Datacenter": "dc1","Node": "tomcat1","Address": "127.0.0.1","Service": { "Id": "127.0.0.1:8090", "Service": "api_tomcat1","tags": [ "dev" ],"Port": 8090}}'