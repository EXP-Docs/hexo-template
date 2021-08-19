#!/bin/bash
# 停止 Hexo 服务
#------------------------------------------------
# 命令执行示例：
# ./stop.sh
#------------------------------------------------

CONTAINER_NAME="hexo-blog"
DOCKER_ID=`docker ps -aq --filter name=${CONTAINER_NAME}`
if [ ! -z "$DOCKER_ID" ]; then
    docker stop $DOCKER_ID
    # docker rm $DOCKER_ID
fi
