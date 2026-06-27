# mdBook 构建（兼容旧 build.ps1 文件名）
docker run --rm -v "$PWD:/workspace" re0-mdbook sh bin/build-mdbook.sh
