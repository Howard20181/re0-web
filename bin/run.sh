#!/bin/sh
# mdBook 本地 Docker 预览（Linux/macOS，兼容旧 run.sh 文件名）
set -e
IMAGE="re0-mdbook"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 按需构建镜像
docker images -q "$IMAGE" >/dev/null 2>&1 || docker build -f Dockerfile.mdbook -t "$IMAGE" "$ROOT"

# 启动
echo "==> Starting mdBook preview ..."
echo "    Once ready, open: http://localhost:4000"
docker run --rm -v "$ROOT:/workspace" -p 4000:4000 "$IMAGE" sh bin/serve-mdbook-docker.sh
