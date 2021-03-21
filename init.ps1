# 构建 Hexo 运行环境
#-----------------------------------------------------------------
# 命令执行示例：
# ./init.ps1 -e "289065406@qq.com" -u "lyy289065406" -d "articles"
#-----------------------------------------------------------------

# e: Github 邮箱
# u: Github 账号
# n: 发布 Hexo 博客内容的 Github 仓库名称（不能是当前仓库）
# d: 博客域名，如 exp-blog.com
param([string]$e="", [string]$u="", [string]$n="", [string]$d="")

# 命令参数定义
$GITHUB_MAIL = "289065406@qq.com"     # -m : Github 邮箱
$GITHUB_USER = "lyy289065406"         # -u : Github 账号
$DEPLOY_REPO_NAME = "articles"        # -n : 发布 Hexo 博客内容的 Github 仓库名称（不能是当前仓库）
$BLOG_DOMAIN = ""                     # -d : 博客域名，如 exp-blog.com
$HEXO_CONFIG = "./hexo/_config.yml"   # Hexo 博客配置文件路径
$IMAGE_NAME = "expm02/hexo-template"      # 构建的 Docker 镜像名称


# 使用说明
function usage {
    Write-Host "-e <github mail>      Github Email"
    Write-Host "-u <github user>      Github Username"
    Write-Host "-n <deploy repo name> The repo (Not this one) for deploying Hexo-Blog's articles"
    Write-Host "-d <domain>           The blog's domain, eg: exp-blog.com"
    return
}
if ([String]::IsNullOrEmpty(${e}) -And [String]::IsNullOrEmpty(${u}) -And [String]::IsNullOrEmpty(${n}) -And [String]::IsNullOrEmpty(${d})) {
    usage
    Exit
}


$GITHUB_MAIL = ${e}
$GITHUB_USER = ${u}
$DEPLOY_REPO_NAME = ${n}
$BLOG_DOMAIN = ${d}

# 若域名为空，则使用 Github Page 的子域名
if ([String]::IsNullOrEmpty(${BLOG_DOMAIN})) {
    $BLOG_DOMAIN = "${GITHUB_USER}.github.io"
}

Write-Host "---------- Input Params ----------"
Write-Host "Github Email = ${GITHUB_MAIL}"
Write-Host "Github Username = ${GITHUB_USER}"
Write-Host "Deploy Repo name = ${DEPLOY_REPO_NAME}"
Write-Host "Blog domain = ${BLOG_DOMAIN}"
Write-Host "Hexo config path = ${HEXO_CONFIG}"
Write-Host "Hexo image name = ${IMAGE_NAME}"
Write-Host "----------------------------------"


# 构建 Hexo 镜像： 用于提供 Hexo 命令的运行环境
Write-Host "Building docker image ..."
docker build -t "${IMAGE_NAME}" --build-arg github_mail=${GITHUB_MAIL} --build-arg github_user=${GITHUB_USER} .


# 设置 Hexo 的内容发布配置
Write-Host "Set hexo deploy config ..."
./_sed.ps1 "^url: .*$" "url: https://${BLOG_DOMAIN}" "${HEXO_CONFIG}"
./_sed.ps1 "^  repo: .*$" "  repo: git@github.com:${GITHUB_USER}/${DEPLOY_REPO_NAME}.git" "${HEXO_CONFIG}"
Set-Content -Path ./hexo/source/CNAME -Value ${BLOG_DOMAIN}


# 根据 package.json 安装 hexo 插件
Write-Host "Install npm plugins ..."
./exec.ps1 npm install


Write-Host "Finish."
