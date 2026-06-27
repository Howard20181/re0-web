#!/bin/sh
# mdBook 构建（兼容旧 build.sh 文件名）
rm -rf mdbook/book
exec bash bin/build-mdbook.sh
