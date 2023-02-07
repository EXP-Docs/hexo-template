#!/bin/bash
# 运行 Hexo 服务
#------------------------------------------------
# 命令执行示例：
# bin/run.sh -p 4000
#------------------------------------------------

PORT=4000
IMAGE_NAME="expm02/hexo-template"
CONTAINER_NAME="hexo-template"

set -- `getopt p: "$@"`
while [ -n "$1" ]
do
  case "$1" in
    -p) PORT="$2"
        shift ;;
  esac
  shift
done

docker run -d --rm \
        -v "${PWD}/hexo:/hexo" \
        -v "${HOME}/.ssh/id_rsa:/root/.ssh/id_rsa" \
        -v "${HOME}/.ssh/known_hosts:/root/.ssh/known_hosts" \
        -p ${PORT}:4000 \
        --name="${CONTAINER_NAME}" \
        ${IMAGE_NAME} \
        sh -c "chmod 400 /root/.ssh/id_rsa && hexo s"
