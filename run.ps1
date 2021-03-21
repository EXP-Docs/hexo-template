# 运行 Hexo 服务
#------------------------------------------------
# 命令执行示例：
# ./run.ps1 -p 4000
#------------------------------------------------

param([int]$p=4000)

if (${p} -lt 0) {
    $PORT = 4000
} else {
    $PORT = ${p}
}

$IMAGE_NAME = "expm02/hexo-blog"
$CONTAINER_NAME = "hexo-blog"

docker run -d --rm `
        -v "${PWD}/hexo:/hexo" `
        -v "${HOME}/.ssh/id_rsa:/root/.ssh/id_rsa" `
        -v "${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts" `
        -p ${PORT}:4000 `
        --name="${CONTAINER_NAME}" `
        ${IMAGE_NAME} `
        sh -c "chmod 400 /root/.ssh/id_rsa && hexo s"
