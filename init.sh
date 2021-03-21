#!/bin/bash
# 构建 Hexo 运行环境
#-----------------------------------------------------------------
# 命令执行示例：
# ./init.sh -e "289065406@qq.com" -u "lyy289065406" -d "articles"
#-----------------------------------------------------------------

# 命令参数定义
GITHUB_MAIL="289065406@qq.com"        # -m : Github 邮箱
GITHUB_USER="lyy289065406"            # -u : Github 账号
DEPLOY_REPO_NAME="articles"           # -n : 发布 Hexo 博客内容的 Github 仓库名称（不能是当前仓库）
BLOG_DOMAIN=""                        # -d : 博客域名，如 exp-blog.com
HEXO_CONFIG="./hexo/_config.yml"      # Hexo 博客配置文件路径
IMAGE_NAME="expm02/hexo-blog"         # 构建的 Docker 镜像名称


# 使用说明
usage()
{
  cat <<EOF
    -h                    This help message.
    -e <github mail>      Github 邮箱
    -u <github user>      Github 账号
    -n <deploy repo name> 发布 Hexo 博客内容的 Github 仓库名称（不能是当前仓库）
    -d <domain>           博客域名，如 exp-blog.com
EOF
  exit 0
}
# [ "$1" = "" ] && usage
[ "$1" = "-h" ] && usage
[ "$1" = "-H" ] && usage


# 定义参数键和值
set -- `getopt e:u:n:d: "$@"`
while [ -n "$1" ]
do
  case "$1" in
    -e) GITHUB_MAIL="$2"
        shift ;;
    -u) GITHUB_USER="$2"
        shift ;;
    -n) DEPLOY_REPO_NAME="$2"
        shift ;;
    -d) BLOG_DOMAIN="$2"
        shift ;;
  esac
  shift
done

# 若域名为空，则使用 Github Page 的子域名
if [ -z "${BLOG_DOMAIN}" ] ; then
  BLOG_DOMAIN="${GITHUB_USER}.github.io"
fi



echo "---------- Input Params ----------"
echo "Github Email = ${GITHUB_MAIL}"
echo "Github Username = ${GITHUB_USER}"
echo "Deploy Repo name = ${DEPLOY_REPO_NAME}"
echo "Blog domain = ${BLOG_DOMAIN}"
echo "Hexo config path = ${HEXO_CONFIG}"
echo "Hexo image name = ${IMAGE_NAME}"
echo "----------------------------------"


# 构建 Hexo 镜像： 用于提供 Hexo 命令的运行环境
echo "Building docker image ..."
docker build -t "${IMAGE_NAME}" --build-arg github_mail=${GITHUB_MAIL} --build-arg github_user=${GITHUB_USER} .


# 设置 Hexo 的内容发布配置
echo "Set hexo deploy config ..."
./_sed.sh "^url: .*$" "url: https:\/\/${BLOG_DOMAIN}" "${HEXO_CONFIG}"
./_sed.sh "^  repo: .*$" "  repo: git@github.com:${GITHUB_USER}\/${DEPLOY_REPO_NAME}.git" "${HEXO_CONFIG}"
echo ${BLOG_DOMAIN} > ./hexo/source/CNAME

# 根据 package.json 安装 hexo 插件
echo "Install npm plugins ..."
./exec.sh npm install


echo "Finish."
