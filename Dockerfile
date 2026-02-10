FROM caddy:builder AS builder

ARG CADDY_VERSION=latest
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# 构建带有 forward_proxy 插件的 Caddy
RUN xcaddy build ${CADDY_VERSION} \
    --with github.com/caddyserver/forwardproxy \
    --with github.com/caddy-dns/cloudflare

FROM caddy:latest

# 添加元数据标签
LABEL maintainer="your-email@example.com" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.title="Caddy Forward Proxy with Cloudflare DNS" \
      org.opencontainers.image.description="Caddy server with forward proxy and Cloudflare DNS plugins" \
      org.opencontainers.image.url="https://hub.docker.com/r/hzdlive/caddy-forward-proxy" \
      org.opencontainers.image.source="https://github.com/hzdlive/caddy-forward-proxy" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="Your Name" \
      org.opencontainers.image.licenses="MIT"

# 复制自定义构建的 Caddy
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:2019/config/ || exit 1

# 暴露端口
EXPOSE 80 443 443/udp 2019

# 默认工作目录
WORKDIR /srv

# 使用非 root 用户运行
USER caddy
