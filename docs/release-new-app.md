# 新应用发布流程

从开发到发布一个新 fnOS 应用的完整流程。本文档基于实际操作经验整理，覆盖构建、测试、发布各环节。

> **前置条件**：已阅读 [新增应用指南](adding-new-apps.md) 并完成应用文件编写。

---

## 1. 文件清单检查

发布前确认以下文件齐全且正确：

### 应用定义 (`apps/<slug>/fnos/`)

| 文件 | 必需 | 说明 |
|------|:---:|------|
| `manifest` | ✅ | 应用元数据（名称、版本、端口、描述等） |
| `cmd/service-setup` | ✅ | 服务启动配置（`SERVICE_COMMAND`、PID/LOG 路径） |
| `cmd/main` | Docker 应用 | Docker 应用需要，用于状态检查（与 vaultwarden 保持一致） |
| `config/privilege` | ✅ | 运行用户与权限组 |
| `config/resource` | ✅ | 端口协议文件、data-share、打包类型（`systemd-unit` / `docker-project`） |
| `<AppName>.sc` | ✅ | 端口防火墙规则 |
| `docker/docker-compose.yaml` | Docker 应用 | Docker Compose 定义 |
| `ui/config` | ✅ | 应用中心 UI 入口配置 |
| `ui/images/64.png` | ✅ | 64×64 应用图标 |
| `ICON.PNG` | ✅ | 90×90 应用图标 |
| `ICON_256.PNG` | ✅ | 256×256 应用图标 |

### 构建脚本 (`scripts/apps/<slug>/`)

| 文件 | 必需 | 说明 |
|------|:---:|------|
| `meta.env` | ✅ | 应用构建元数据（`APP_SLUG`、`DISPLAY_NAME`、GitHub 信息等） |
| `build.sh` | ✅ | 下载上游产物，生成 `app.tgz` |
| `get-latest-version.sh` | ✅ | 查询上游最新版本号 |
| `release-notes.tpl` | ✅ | Release Notes 模板 |

### CI 入口 (`.github/workflows/`)

| 文件 | 必需 | 说明 |
|------|:---:|------|
| `build-<slug>.yml` | ✅ | 触发条件：push 到 `apps/<slug>/**`、每日 cron、手动触发 |

### 注册

| 位置 | 操作 |
|------|------|
| `reusable-build-app.yml` 第 7 行 | 在 `description` 中追加 slug |
| `reusable-build-app.yml` 第 50 行 | 在 `VALID_APPS` 中追加 slug |

---

## 2. 本地构建测试

在本地或 fnOS 设备上验证 fpk 构建：

```bash
# 1. 运行 build.sh 生成 app.tgz
cd fnos-apps
VERSION=<version> bash scripts/apps/<slug>/build.sh

# 2. 打包为 fpk
bash scripts/build-fpk.sh apps/<slug> app.tgz <version> x86

# 产物：<slug>_<version>_x86.fpk
```

### Docker 应用注意事项

- `build.sh` 负责将 `docker-compose.yaml` 中的 `${VERSION}` 替换为实际版本号
- 某些镜像的 Docker Hub tag 带 `v` 前缀（如 `adguard/adguardhome:v0.107.72`），此时 docker-compose.yaml 中应写为 `image: xxx:v${VERSION}`
- 校验方法：`docker pull <image>:<tag>` 确认 tag 存在

### 常见 tag 格式

| 镜像来源 | tag 格式 | docker-compose 写法 |
|----------|----------|---------------------|
| kodcloud/kodbox | `1.63`（无前缀） | `${VERSION}` |
| linuxserver/* | `4.1.0-r0-ls330`（无前缀） | `${VERSION}` |
| adguard/adguardhome | `v0.107.72`（v 前缀） | `v${VERSION}` |
| jlesage/* | `v26.02.2`（v 前缀） | `v${VERSION}` |

---

## 3. 设备安装测试

将 fpk 安装到 fnOS 设备上验证：

```bash
# 复制 fpk 到设备
scp <slug>_<version>_x86.fpk root@<device>:/tmp/

# 安装
ssh root@<device>
appcenter-cli install-fpk /tmp/<slug>_<version>_x86.fpk

# 启动
appcenter-cli start <slug>

# 验证状态
appcenter-cli status <slug>

# 验证端口
curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>
```

### appcenter-cli 常用命令

```bash
appcenter-cli list                      # 查看所有已安装应用
appcenter-cli status <slug>             # 查看应用状态
appcenter-cli start <slug>              # 启动应用
appcenter-cli stop <slug>               # 停止应用
appcenter-cli uninstall <slug>          # 卸载应用
appcenter-cli install-fpk <file.fpk>    # 安装 fpk
appcenter-cli default-volume            # 查看/设置默认安装存储空间
```

### 安装失败排查

Docker 应用安装失败常见原因：

1. **Docker 镜像 tag 不存在**：`appcenter-cli` 日志会显示 `APP_INSTALL_FAILED_INIT_DOCKER_EXCEPTION`。检查 docker-compose.yaml 中的镜像 tag 是否正确（注意 `v` 前缀）
2. **镜像拉取失败**：国内网络可能无法访问 Docker Hub，需提前手动 `docker pull` 或配置镜像加速
3. **端口冲突**：目标端口已被其他服务占用

查看详细错误日志：
```bash
journalctl -u trim_app_center --since "5 minutes ago" --no-pager
```

---

## 4. 提交与发布

### 提交代码

```bash
git add apps/<slug>/ scripts/apps/<slug>/ \
        .github/workflows/build-<slug>.yml \
        .github/workflows/reusable-build-app.yml

git commit -m 'feat: add <display-name> app (<slug>, port <port>)'
git push origin main
```

### CI 自动流程

推送到 main 后，CI 自动执行：

1. **版本检查**：`get-latest-version.sh` 获取上游最新版本
2. **Release tag 检查**：如果 `<slug>/v<version>` 已存在则跳过（幂等）
3. **矩阵构建**：x86 + arm 双架构并行构建
4. **创建 Release**：上传 fpk 文件 + 生成 Release Notes
5. **更新 apps.json**：触发 `Update apps.json` workflow，供 fnOS Apps Store 发现新应用

### 验证发布

```bash
# 查看 CI 运行状态
gh run list --repo conversun/fnos-apps --limit 5

# 查看 Release
gh release view <slug>/v<version> --repo conversun/fnos-apps

# 确认双架构产物
gh release view <slug>/v<version> --json assets --jq '.assets[].name'
# 期望输出：
#   <slug>_<version>_arm.fpk
#   <slug>_<version>_x86.fpk
```

---

## 5. 发布后

### 更新文档

- [ ] `README.md` — 在应用表格中添加新应用行 + Release 链接
- [ ] `AGENTS.md` — 更新应用数量和目录说明（如有）

### 回复 Issue

如果新应用源于用户的 App Request issue，回复并关闭：

```bash
gh issue comment <number> --repo conversun/fnos-apps --body "已发布 ✅ ..."
gh issue close <number> --repo conversun/fnos-apps --reason completed
```

### 后续维护

CI 每日 08:00 UTC 自动检查上游版本。如果发现新版本：
- 自动构建新的 fpk
- 创建新的 Release（tag 递增，如 `<slug>/v1.2.3`）
- 更新 apps.json

如需手动触发构建：
```bash
gh workflow run "Build <DisplayName> fnOS Package" --repo conversun/fnos-apps
```

如需指定版本或修订号：
```bash
gh workflow run "Build <DisplayName> fnOS Package" \
  --repo conversun/fnos-apps \
  -f version=1.2.3 \
  -f revision=r2
```
