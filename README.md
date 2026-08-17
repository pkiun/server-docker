# server-docker

Pupy C2 服务端 (pupysh) 的 Docker 镜像。GitHub Actions 自动构建并推送到 Docker Hub：

- 镜像：`pikun223/pupy-server`（`latest` / commit sha）
- 架构：linux/amd64 + linux/arm64

## 构建

推送 main 分支或手动触发 `workflow_dispatch` 即可。需要仓库 Secrets：

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## 本地运行

```sh
docker run -d --name pupy-server \
  -p 443:443 \
  -v pupy-data:/data \
  -e PUPY_LISTEN="ssl 0.0.0.0:443" \
  pikun223/pupy-server
```

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `PUPY_LISTEN` | `ssl 0.0.0.0:443` | 监听器，支持多个：`-e PUPY_LISTEN="ssl 0.0.0.0:443 -l kcp 80"` |
| `PUPY_WORKDIR` | `/data` | 服务端数据目录（证书、凭据、配置），建议挂载 volume |

### 生成 payload

服务端镜像同时包含 `pupygen`，可交互式进入容器生成 payload：

```sh
docker exec -it pupy-server pupysh -l "tcp 127.0.0.1:4444"
```

## 原理

- 基于 `python:3.11-slim` 多阶段构建，从 `https://github.com/n1nj4sec/pupy` 的 `nextgen` 分支安装。
- `entrypoint.sh` 通过 FIFO 保持 stdin 打开，使 `pupysh` 控制台在后台运行时不会因 EOF 退出。
- `pupysh --workdir /data` 以 root 运行时会把用户/组降级为数据目录属主。