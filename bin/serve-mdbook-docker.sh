#!/bin/sh
# Docker 容器内的 mdBook 预览入口脚本
# 由 bin/run-mdbook.ps1 / bin/run.sh 调用
# 运行环境：容器内，工作目录 = /workspace（即仓库根目录）
#
# 注：源文件已在 mdbook/src/ 中，不再需要从 gitbook/ 复制

set -e

ROOT=$(pwd)

echo "==> Fixing .html links in chapter README.md..."
find "$ROOT/mdbook/src/markdown" -name "README.md" -print0 \
    | xargs -0 sed -i 's/\.html)/.md)/g'

echo "==> Fixing absolute /res/ paths..."
python3 "$ROOT/bin/fix-res-paths.py" "$ROOT/mdbook/src"

echo "==> Adapting SUMMARY.md to mdBook format..."
python3 "$ROOT/bin/adapt-summary.py" "$ROOT/mdbook/src/SUMMARY.md" "$ROOT/mdbook/src/SUMMARY.md"

echo ""
echo "==> Building book and generating SEO files ..."
echo ""

# 1. 用 mdbook build 生成静态站点
cd "$ROOT/mdbook" && mdbook build

# 2. 生成 sitemap 和 RSS（mdbook 的 warp 路由不认识这些外来文件，不能依赖它服务）
SITE_URL="http://localhost:4000"
echo "[serve] Generating sitemap.xml..."
python3 "$ROOT/bin/gen-sitemap.py" "$ROOT/mdbook/book" "$SITE_URL" "$ROOT/mdbook/book/sitemap.xml"
echo "[serve] Generating rss.xml..."
python3 "$ROOT/bin/gen-rss.py" "$ROOT/mdbook/src/SUMMARY.md" "$SITE_URL" "$ROOT/mdbook/book/rss.xml"

# 3. 用 Python http.server 服务整个 book 目录（确保 rss/sitemap 等所有文件均可访问）
echo ""
echo "==> Serving on http://localhost:4000"
echo "    Home:    http://localhost:4000/"
echo "    RSS:     http://localhost:4000/rss.xml"
echo "    Sitemap: http://localhost:4000/sitemap.xml"
echo "    (Ctrl+C to stop)"
echo ""

cd "$ROOT/mdbook/book" && python3 -m http.server --bind 0.0.0.0 4000
