# 生成 Hexo 发布内容
#-----------------------------------------------------------------
# 命令执行示例：
#  测试环境：                ./build.ps1 -e test
#  生产环境（自定义域名）：    ./build.ps1 -e prod
#  生产环境（无自定义域名）：  ./build.ps1 -e prod -d no
#-----------------------------------------------------------------
# 命令执行示例：
# bin/build.ps1 -e "prod" -d "no"
#-----------------------------------------------------------------

# e: 发布环境，prod 为生产环境，其他值为测试环境
# d: 声明是否有自定义域名，no 表示无，其他值表示有
param([string]$e="", [string]$d="")


$ENV = "${e}"                          # 发布环境
$USEDOMAIN = "${d}"                    # 声明是否有自定义域名(默认有)
$HEXO_CONFIG = "./hexo/_config.yml"    # Hexo 博客配置文件路径
$GITHUB_USER = ((Get-Content ${HEXO_CONFIG} -encoding utf8 | Select-String -pattern "  repo: ") -Split "[:/]")[2]
$GITHUB_DOMAIN = "https://${GITHUB_USER}.github.io"
$CUSTOM_DOMAIN = "https://" + (Get-Content ./hexo/source/CNAME)


# 停止 Hexo 服务
bin/stop.ps1

# 设置测试环境参数
if (!(${ENV} -Eq "prod")) {
    $CUR_REPO_URL = ((git remote -v) -Split "\s")[1]
    $CUR_REPO_NAME = (${CUR_REPO_URL} -Split "[/\.]")[5]
    bin/_sed.ps1 "^url: .*$" "url: ${GITHUB_DOMAIN}" "${HEXO_CONFIG}"
    bin/_sed.ps1 "^root: .*$" "root: /${CUR_REPO_NAME}/hexo/public/" "${HEXO_CONFIG}"

# 设置生产环境参数
} else {
    $DEPLOY_REPO_NAME = ((Get-Content ${HEXO_CONFIG} -encoding utf8 | Select-String -pattern "  repo: ") -Split "[/\.]")[2]
    bin/_sed.ps1 "^url: .*$" "url: ${CUSTOM_DOMAIN}" "${HEXO_CONFIG}"

    # Github 子域名
    if (${USEDOMAIN} -Eq "no") {
        bin/_sed.ps1 "^root: .*$" "root: /${DEPLOY_REPO_NAME}/hexo/public/" "${HEXO_CONFIG}"

    # 自定义域名
    } else {
        bin/_sed.ps1 "^root: .*$" "root: /" "${HEXO_CONFIG}"
    }

}


# 清除历史内容
bin/exec.ps1 hexo clean

# 生成博客内容
bin/exec.ps1 hexo g

# 发布到生产环境的博客仓库
if (${ENV} -Eq "prod") {
    bin/exec.ps1 hexo d
}

# 恢复生产环境参数（自定义域名）
$DEPLOY_REPO_NAME = ((Get-Content ${HEXO_CONFIG} -encoding utf8 | Select-String -pattern "  repo: ") -Split "[/\.]")[2]
bin/_sed.ps1 "^url: .*$" "url: ${CUSTOM_DOMAIN}" "${HEXO_CONFIG}"
bin/_sed.ps1 "^root: .*$" "root: /" "${HEXO_CONFIG}"
