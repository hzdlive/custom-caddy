# GitHub Actions 自动构建 Docker 镜像配置指南

本项目包含三种 GitHub Actions 工作流配置，用于自动构建并推送 Docker 镜像到 Docker Hub。

## 📁 文件说明

```
.github/workflows/
├── docker-build-simple.yml      # 简单版（推荐新手）
├── docker-build.yml             # 标准版（推荐）
└── docker-build-advanced.yml    # 高级版（多架构、多变体）
```

## 🚀 快速开始

### 第一步：选择工作流

根据你的需求选择一个工作流文件：

#### 1. **docker-build-simple.yml** - 最简单
- ✅ 适合快速开始
- ✅ 配置简单
- ❌ 仅支持 AMD64 架构
- ❌ 功能较少

#### 2. **docker-build.yml** - 推荐使用
- ✅ 支持多架构（AMD64, ARM64, ARM v7）
- ✅ 自动版本标签
- ✅ 自动更新 Docker Hub 描述
- ✅ 构建缓存优化

#### 3. **docker-build-advanced.yml** - 高级功能
- ✅ 支持多个镜像变体（标准版、Alpine 版）
- ✅ 安全扫描（Trivy）
- ✅ 同时推送到 Docker Hub 和 GitHub Container Registry
- ✅ 定时构建
- ✅ 手动触发选项

### 第二步：配置 GitHub Secrets

在 GitHub 仓库中设置以下 Secrets：

1. 进入仓库 Settings > Secrets and variables > Actions
2. 点击 "New repository secret"
3. 添加以下 Secrets：

#### 必需的 Secrets：

| Secret 名称 | 说明 | 如何获取 |
|------------|------|---------|
| `DOCKERHUB_USERNAME` | Docker Hub 用户名 | 你的 Docker Hub 用户名 |
| `DOCKERHUB_TOKEN` | Docker Hub 访问令牌 | 见下方获取步骤 |

#### 获取 Docker Hub Access Token：

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 > Account Settings
3. Security > New Access Token
4. Token description: `GitHub Actions`
5. Access permissions: `Read, Write, Delete`
6. Generate Token
7. **立即复制 Token**（只显示一次！）
8. 在 GitHub 中添加为 `DOCKERHUB_TOKEN`

### 第三步：修改配置文件

#### 修改 Dockerfile

编辑 `Dockerfile` 中的标签信息：

```dockerfile
LABEL maintainer="your-email@example.com" \
      org.opencontainers.image.source="https://github.com/your-username/your-repo"
```

#### 修改工作流文件

**对于 docker-build-simple.yml：**

```yaml
env:
  IMAGE_NAME: your-dockerhub-username/caddy-forward-proxy
```

**对于 docker-build.yml：**

```yaml
env:
  DOCKER_IMAGE: your-dockerhub-username/caddy-forward-proxy
```

**对于 docker-build-advanced.yml：**

```yaml
env:
  IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/caddy-forward-proxy
```

### 第四步：删除不需要的工作流

如果你选择使用其中一个工作流，可以删除其他的：

```bash
# 保留简单版，删除其他
rm .github/workflows/docker-build.yml
rm .github/workflows/docker-build-advanced.yml

# 或保留标准版，删除其他
rm .github/workflows/docker-build-simple.yml
rm .github/workflows/docker-build-advanced.yml
```

### 第五步：推送到 GitHub

```bash
git add .
git commit -m "Add GitHub Actions workflow"
git push origin main
```

## 🎯 触发构建

### 自动触发

工作流会在以下情况自动运行：

#### docker-build-simple.yml
- ✅ Push 到 `main` 分支
- ✅ 创建 `v*` 标签（如 v1.0.0）

#### docker-build.yml
- ✅ Push 到 `main` 或 `master` 分支
- ✅ 创建 `v*.*.*` 标签
- ✅ Pull Request 到 `main` 或 `master`（仅构建，不推送）

#### docker-build-advanced.yml
- ✅ Push 到 `main` 或 `develop` 分支
- ✅ 创建 `v*.*.*` 标签
- ✅ Pull Request 到 `main`
- ✅ 每周一凌晨 2 点自动构建

### 手动触发

#### docker-build.yml 和 docker-build-advanced.yml 支持手动触发：

1. 进入 GitHub 仓库
2. Actions 标签
3. 选择工作流
4. Run workflow 按钮
5. 选择分支
6. Run workflow

## 📦 生成的镜像标签

### 标准版工作流生成的标签：

```bash
# Push 到 main 分支
your-username/caddy-forward-proxy:latest
your-username/caddy-forward-proxy:main
your-username/caddy-forward-proxy:main-abc1234

# 创建版本标签 v1.2.3
your-username/caddy-forward-proxy:1.2.3
your-username/caddy-forward-proxy:1.2
your-username/caddy-forward-proxy:1
your-username/caddy-forward-proxy:latest

# Pull Request #42
your-username/caddy-forward-proxy:pr-42
```

### 高级版工作流（包含 Alpine 变体）：

```bash
# 标准版
your-username/caddy-forward-proxy:latest
your-username/caddy-forward-proxy:1.2.3

# Alpine 版
your-username/caddy-forward-proxy:alpine
your-username/caddy-forward-proxy:1.2.3-alpine
```

## 🏗️ 支持的架构

| 工作流 | 支持的架构 |
|-------|-----------|
| Simple | linux/amd64 |
| Standard | linux/amd64, linux/arm64, linux/arm/v7 |
| Advanced | linux/amd64, linux/arm64, linux/arm/v7 |

## 📊 查看构建状态

### 添加徽章到 README.md

```markdown
![Docker Build](https://github.com/your-username/your-repo/actions/workflows/docker-build.yml/badge.svg)
```

### 查看构建日志

1. 进入 GitHub 仓库
2. Actions 标签
3. 点击具体的工作流运行
4. 查看每个步骤的日志

## 🔧 高级配置

### 1. 修改支持的架构

编辑工作流文件的 `PLATFORMS` 环境变量：

```yaml
env:
  PLATFORMS: linux/amd64,linux/arm64
  # 移除 ARM v7 支持，仅保留 AMD64 和 ARM64
```

### 2. 添加更多 Docker Registry

**同时推送到 GitHub Container Registry：**

在 `docker-build.yml` 中添加：

```yaml
- name: Log in to GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

- name: Extract metadata
  id: meta
  uses: docker/metadata-action@v5
  with:
    images: |
      ${{ env.DOCKER_IMAGE }}
      ghcr.io/${{ github.repository }}
```

### 3. 自定义构建参数

在 `Build and push` 步骤中添加：

```yaml
build-args: |
  CADDY_VERSION=v2.7.6
  CUSTOM_ARG=value
```

## 🐛 故障排查

### 问题 1: "Invalid username or password"

**解决方案：**
- 确认 `DOCKERHUB_USERNAME` 是用户名，不是邮箱
- 重新生成 `DOCKERHUB_TOKEN`
- 确认 Secrets 名称拼写正确

### 问题 2: "Image not found"

**解决方案：**
- 确认镜像名称格式：`username/repository`
- 检查工作流中的 `DOCKER_IMAGE` 或 `IMAGE_NAME`
- 确认 Docker Hub 仓库已创建

### 问题 3: 构建超时

**解决方案：**
- 减少支持的架构数量
- 启用构建缓存
- 考虑使用自托管 Runner

## 📈 最佳实践

### 1. 使用语义化版本

```bash
# 创建版本标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 2. 保护主分支

在 GitHub 仓库设置中：
- Settings > Branches
- Add rule for `main`
- Require pull request reviews
- Require status checks (选择构建工作流)

## 💡 测试构建的镜像

```bash
# 测试构建的镜像
docker pull your-username/caddy-forward-proxy:latest
docker run -d -p 443:443 your-username/caddy-forward-proxy:latest
```
