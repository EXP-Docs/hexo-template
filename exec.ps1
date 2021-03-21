# 利用 Hexo 镜像执行 Hexo 命令
#------------------------------------------------
# 命令执行示例：
# ./exec.ps1 "nmp install"
#------------------------------------------------

$HEXO_CMD = ${args}
$IMAGE_NAME="expm02/hexo-template"

# 因为 hexo 主要是通过 ssh 发布内容到 Github 仓库的，故此处挂载宿主机的 id_rsa 和 known_hosts 是必须的
# known_hosts 是在配置公钥 id_rsa.pub 到 Github 后，执行命令 ssh -T git@github.com 生成的
# 详见： https://help.github.com/en/articles/connecting-to-github-with-ssh
# 另因挂载 id_rsa 时默认权限为 777，会导致 ssh 安全检测异常连接失败，故追加 chmod 400 命令
docker run --rm `
        -v "${PWD}/hexo:/hexo" `
        -v "${HOME}/.ssh/id_rsa:/root/.ssh/id_rsa" `
        -v "${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts" `
        ${IMAGE_NAME} `
        sh -c "chmod 400 /root/.ssh/id_rsa && ${HEXO_CMD}"
