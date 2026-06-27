# mdBook 构建（兼容旧 build.ps1 文件名）

$ErrorActionPreference = "Stop"
$ROOT = (Resolve-Path "$PSScriptRoot\..").Path
Set-Location $ROOT

$IMAGE = "re0-mdbook"

$imageExists = docker images -q $IMAGE 2>$null
if (-not $imageExists) {
    docker build -f Dockerfile.mdbook -t $IMAGE .
}

# Docker 挂载卷下容器内清理 mdbook/book 不可靠，Windows 侧先清理
cmd /c "rmdir /s /q mdbook\book 2>nul"

docker run --rm -v "${ROOT}:/workspace" $IMAGE sh bin/build-mdbook.sh
