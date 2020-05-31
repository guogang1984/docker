docker pull postgres:10-alpine

### postgres
create user sonar with password 'sonar';
create database sonar owner sonar; 
grant all on database sonar to sonar;

docker build -t g127/postgres:10-alpine .


```bash
docker run -d \
    --name postgres \
    -e POSTGRES_USER='root' \
    -e POSTGRES_PASSWORD='root' \
    -e POSTGRES_DB='postgres' \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v $HOME/DevProjectFiles/ws-data/postgres:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:10-alpine
```

```bash
docker run -d \
    --name postgres \
    -v $HOME/DevProjectFiles/ws-data/postgres:/var/lib/postgresql/data \
    -p 5432:5432 \
    g127/postgres:10-alpine
```

## huawei cce
### 2. 操作步骤:
Step 1. 以root用户登录Docker所在的虚拟机

Step 2. 获取登录Docker访问权限，并复制到节点上执行

生成临时docker login指令 或查看 如何获取长期有效docker login指令 。
Step 3. 上传镜像

$ sudo docker tag [{镜像名称}:{版本名称}] swr.cn-north-4.myhuaweicloud.com/{组织名称}/{镜像名称}:{版本名称}

$ sudo docker push swr.cn-north-4.myhuaweicloud.com/{组织名称}/{镜像名称}:{版本名称}

### 具体
# 
docker login -u cn-north-4@QG3PAJLYR3JYH04Q2LXG -p feae912f408ccbf6cd50a085c31bfaf15b86c4e374a3b5186691f279c6e1fcfa swr.cn-north-4.myhuaweicloud.com

#
docker tag g127/postgres:10-alpine swr.cn-north-4.myhuaweicloud.com/g127/postgres:10-alpine

#
docker push swr.cn-north-4.myhuaweicloud.com/g127/postgres:10-alpine