#!/bin/bash
# 生成 Hexo 发布内容
#-----------------------------------------------------------------
# 命令执行示例：
#  测试环境：                ./build.sh -e test
#  生产环境（自定义域名）：    ./build.sh -e prod
#  生产环境（无自定义域名）：  ./build.sh -e prod -d no
#-----------------------------------------------------------------

ENV="test"                          # 发布环境
USEDOMAIN=""                        # 声明是否有自定义域名(默认有)
HEXO_CONFIG="./hexo/_config.yml"    # Hexo 博客配置文件路径
GITHUB_USER=`cat ${HEXO_CONFIG} | grep "  repo: " | awk -F '[:/]' '{print $3}'`
GITHUB_DOMAIN="https://${GITHUB_USER}.github.io"
CUSTOM_DOMAIN="https://"`cat ./hexo/source/CNAME`

set -- `getopt e:d: "$@"`
while [ -n "$1" ]
do
  case "$1" in
    -e) ENV="$2"
        shift ;;
    -d) USEDOMAIN="$2"
        shift ;;
  esac
  shift
done


# 停止 Hexo 服务
./stop.sh

# 设置测试环境参数
if [[ ${ENV} != "prod" ]] ; then
    CUR_REPO_URL=`git remote -v | tail -1 | awk '{print $2}'`
    CUR_REPO_NAME=${CUR_REPO_URL##*/}
    CUR_REPO_NAME=${CUR_REPO_NAME%%\.git}
    ./_sed.sh "^url: .*$" "url: ${GITHUB_DOMAIN//\//\\/}" "${HEXO_CONFIG}"
    ./_sed.sh "^root: .*$" "root: \/${CUR_REPO_NAME}\/hexo\/public\/" "${HEXO_CONFIG}"

# 设置生产环境参数
else
    DEPLOY_REPO_NAME=`cat ${HEXO_CONFIG} | grep "  repo: " | awk -F '[./]' '{print $3}'`
    ./_sed.sh "^url: .*$" "url: ${CUSTOM_DOMAIN//\//\\/}" "${HEXO_CONFIG}"

    # Github 子域名
    if [[ ${USEDOMAIN} = "no" ]] ; then
        ./_sed.sh "^root: .*$" "root: \/${DEPLOY_REPO_NAME}\/" "${HEXO_CONFIG}"

    # 自定义域名
    else
        ./_sed.sh "^root: .*$" "root: \/" "${HEXO_CONFIG}"
    fi
fi

# 清除历史内容
./exec.sh hexo clean

# 生成博客内容
./exec.sh hexo g

# 发布到生产环境的博客仓库
if [[ ${ENV} = "prod" ]] ; then
    ./exec.sh hexo d
fi

# 恢复生产环境参数（自定义域名）
DEPLOY_REPO_NAME=`cat ${HEXO_CONFIG} | grep "  repo: " | awk -F '[./]' '{print $3}'`
./_sed.sh "^url: .*$" "url: ${CUSTOM_DOMAIN//\//\\/}" "${HEXO_CONFIG}"
./_sed.sh "^root: .*$" "root: \/" "${HEXO_CONFIG}"
