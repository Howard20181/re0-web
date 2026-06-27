# mdBook 构建镜像（兼容旧 Dockerfile 文件名）
# 实际构建使用 Dockerfile.mdbook
FROM debian:bookworm-slim

ARG MDBOOK_VERSION=0.4.40

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl ca-certificates python3 && \
    curl -sSL \
        "https://github.com/rust-lang/mdBook/releases/download/v${MDBOOK_VERSION}/mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
        | tar -xz -C /usr/local/bin/ && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
EXPOSE 4000
