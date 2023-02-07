# 停止 Hexo 服务
#------------------------------------------------
# 命令执行示例：
# bin/stop.ps1
#------------------------------------------------

$CONTAINER_NAME = "hexo-template"
$DOCKER_ID = (docker ps -aq --filter name=${CONTAINER_NAME})
if(![String]::IsNullOrEmpty($DOCKER_ID)) {
    docker stop ${DOCKER_ID}
    # docker rm $DOCKER_ID
}
