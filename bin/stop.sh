#!/bin/sh
# 停止 mdBook 容器（兼容旧 stop.sh 文件名）
docker ps -q --filter ancestor=re0-mdbook | xargs -r docker stop
