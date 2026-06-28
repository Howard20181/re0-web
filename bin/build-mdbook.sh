#!/bin/sh
# mdBook 构建脚本
# 源文件位于 mdbook/src/，构建输出到 mdbook/book/
# GitHub Actions 要求可执行位 (+x)，本地提交时通过 git add --chmod=+x 设置

set -e

MDBOOK_VERSION="0.4.40"
ROOT_DIR=$(pwd)

# 优先使用系统 PATH 里的 mdbook（如 Docker 镜像内），否则使用本地下载版
if command -v mdbook >/dev/null 2>&1; then
    MDBOOK_BIN=$(command -v mdbook)
else
    MDBOOK_BIN="$ROOT_DIR/mdbook/bin/mdbook"
fi
SRC_DIR="mdbook/src"

# GitHub Actions/Linux 可直接清理输出目录；Windows Docker 挂载卷失败时不阻断，交给本地 wrapper 清理。
rm -rf mdbook/book 2>/dev/null || true

# ── 1. 修复章节索引页的 .html 链接 ───────────────────────────
# README.md 里的 (01.html) 链接需要改成 (01.md)，mdBook 才能正确解析
echo "==> Fixing .html links in chapter README.md files..."
find "$SRC_DIR/markdown" -name "README.md" -print0 \
    | xargs -0 sed -i 's/\.html)/.md)/g'

# ── 2. 修复 /res/ 绝对路径为相对路径 ─────────────────────────
# mdBook 不会转换根路径，需要预处理
echo "==> Fixing absolute /res/ paths to relative..."
python3 bin/fix-res-paths.py "$SRC_DIR"

# ── 3. 转换 SUMMARY.md 格式 ──────────────────────────────────
# 将 GitBook 格式的 SUMMARY.md 转为 mdBook 格式
echo "==> Adapting SUMMARY.md..."
python3 bin/adapt-summary.py "$SRC_DIR/SUMMARY.md" "$SRC_DIR/SUMMARY.md"

# ── 4. 下载 mdBook 二进制（仅在 PATH 中不存在且本地也没有时）────────
if [ ! -f "$MDBOOK_BIN" ]; then
    echo "==> Downloading mdBook v${MDBOOK_VERSION}..."
    mkdir -p mdbook/bin
    curl -sSL \
        "https://github.com/rust-lang/mdBook/releases/download/v${MDBOOK_VERSION}/mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
        | tar -xz -C mdbook/bin
fi

# ── 5. 构建 ─────────────────────────────────────────────────
echo "==> Building with mdBook v${MDBOOK_VERSION} (bin: ${MDBOOK_BIN})..."
START=$(date +%s)

cd mdbook && "$MDBOOK_BIN" build

END=$(date +%s)
echo "==> Build finished in $((END - START)) seconds."
echo "    Output: mdbook/book/"

# ── 6. 生成 sitemap.xml ──────────────────────────────────────
cd ..
SITE_URL="https://re0zero.top"
echo "==> Generating sitemap.xml..."
python3 bin/gen-sitemap.py mdbook/book "$SITE_URL" mdbook/book/sitemap.xml

# ── 7. 生成 rss.xml ──────────────────────────────────────────
echo "==> Generating rss.xml..."
python3 bin/gen-rss.py mdbook/src/SUMMARY.md "$SITE_URL" mdbook/book/rss.xml

echo "==> All done."
