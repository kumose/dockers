# kumo-dockers

面向多发行版、多架构的 Linux CI/CD 测试用 Docker 镜像矩阵。

[English](./README.md)

## 动机

不同的 Linux 发行版携带不同版本的 glibc、libstdc++、cmake、ninja 等构建工具。为确保跨发行版兼容性，本仓库提供了一系列 Docker 镜像，覆盖主流 Linux 生态：

- **Ubuntu** — glibc，apt，主流桌面/服务器
- **Debian** — glibc，apt，保守/稳定
- **Alpine** — musl libc，apk，极小体积
- **CentOS Stream** — glibc，dnf，RHEL 生态

每个镜像同时构建 `amd64` 和 `arm64` 两种架构。

## 镜像命名

所有镜像以 `kumo-` 命名空间发布：

```
kumo-<发行版名称><版本>-<架构>
```

示例：`kumo-ubuntu24-amd64`、`kumo-alpine320-arm64`、`kumo-centos9-amd64`。

推送时每个镜像同时打 `<version>` 和 `latest` 两个标签。

## 仓库结构

```
dockers/
├── .github/workflows/docker.yml    # CI：自动检测变化、手动推送
├── README.md                       # 英文文档
├── README_CN.md                    # 本文档
├── scripts/
│   └── build.sh                    # 构建 + 推送脚本
├── <发行版名><版本>/                # 如 ubuntu24、debian12、alpine320
│   ├── Dockerfile                  # 多架构（使用 TARGETARCH）
│   └── VERSION                     # 该镜像的语义版本号
└── ...
```

## 版本管理

每个系统目录下有独立的 `VERSION` 文件，内容为 semver 版本号（如 `1.0.0`）。推送时镜像会同时打上版本号和 `latest` 标签。

发布新版本的流程：
1. 修改对应系统的 `VERSION` 文件（如 `1.0.0` → `1.1.0`）
2. commit 并 push 到 `master`
3. 进入 GitHub Actions → `Build Docker Images` → `Run workflow` → 选择 `auto` + 勾选 `Push`

## 规划中的镜像

| 镜像名                          | 基础发行版                   | libc    | 版本  |
|---------------------------------|------------------------------|---------|-------|
| `kumo-ubuntu20-{amd64,arm64}`   | Ubuntu 20.04 (Focal)         | glibc   | 1.0.0 |
| `kumo-ubuntu22-{amd64,arm64}`   | Ubuntu 22.04 (Jammy)         | glibc   | 1.0.0 |
| `kumo-ubuntu24-{amd64,arm64}`   | Ubuntu 24.04 (Noble)         | glibc   | 1.0.0 |
| `kumo-debian11-{amd64,arm64}`   | Debian 11 (Bullseye)         | glibc   | 1.0.0 |
| `kumo-debian12-{amd64,arm64}`   | Debian 12 (Bookworm)         | glibc   | 1.0.0 |
| `kumo-alpine319-{amd64,arm64}`  | Alpine 3.19                  | musl    | 1.0.0 |
| `kumo-alpine320-{amd64,arm64}`  | Alpine 3.20                  | musl    | 1.0.0 |
| `kumo-centos9-{amd64,arm64}`    | CentOS Stream 9              | glibc   | 1.0.0 |

## 使用方法

### 本地构建验证

```bash
./scripts/build.sh <名称> <架构>
```

例如：

```bash
./scripts/build.sh ubuntu24 amd64
./scripts/build.sh ubuntu24 arm64
```

### 构建并推送

```bash
REGISTRY=ghcr.io/kumose ./scripts/build.sh --push ubuntu24 amd64
```

## CI 行为

| 触发方式 | 行为 | 推送？ |
|---------|------|--------|
| 推送 `master`（Dockerfile/VERSION 变化） | 只构建变化的系统 | 否 |
| Pull request | 只构建变化的系统 | 否 |
| `workflow_dispatch` + `auto` | 构建最近一次 commit 变化的系统 | 否 |
| `workflow_dispatch` + `auto` + `push=true` | 构建变化的系统并推送 | 是 |
| `workflow_dispatch` + 指定系统 | 只构建指定系统 | 根据 push 标志 |
| `workflow_dispatch` + 指定系统 + `push=true` | 构建并推送指定系统 | 是 |

## CI 集成

其他仓库的 CI 可以这样使用这些镜像：

```yaml
- name: Pull image
  run: docker pull ghcr.io/kumose/kumo-ubuntu24-amd64:1.0.0

- name: Run tests in container
  run: |
    docker run --rm ghcr.io/kumose/kumo-ubuntu24-amd64:latest ./run-tests.sh
```

## 许可证

MIT
