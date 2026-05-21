## 2026-05-21

- **Setup code 流程** (替代 ZF_TOKEN 旧路径)：安装向导 + post-install 提示
  改为引导用户去容器日志里读 6 位 Setup code (`ZF-XXXX`) 并填到 iOS app
  → 更多 → 桥接 → 输入设置码。`docker-compose.yaml` 移除 `ZF_TOKEN`
  env，wizard 表单移除 token 输入框。无需先打开 iOS app 即可装机配对。
- **AppArmor 兼容**：`security_opt: [apparmor:unconfined]` 让 fnOS 默认
  AppArmor `docker-default` profile 不挡 docker.sock 访问（BUG-20260512-33）。
- **运行账号 + 镜像 pin**：`user: "0:0"` + `image: ...:latest` +
  `pull_policy: always`，让 iOS app 的「升级」按钮通过 docker socket
  真正拉新镜像 (BUG-20260512-34)。Pin `:latest` 而不是 `${VERSION}` 是
  因为 fnOS 重启容器会用缓存 hash，pin 版本号会锁死 1-tap 升级。
- **房间改名 / 队列重排 / 收藏写入** 等 iOS 端新功能由对应 bridge image
  (0.1.78-room-rename / 0.1.77-queue-reorder / 0.1.74-fav-dup-graceful)
  自动覆盖，fnOS 用户无需重装，下次 iOS 端「升级」即可。

## 2026-05-12

- 启用 1-tap self-update：挂载 `/var/run/docker.sock` + `group_add: ["999"]`，让 ZoneFoundry iOS app 的"升级"按钮直接拉取并应用新镜像，不用 SSH 或 Container Manager
- 跟 Unraid CA 模板 (`selfhosters/unRAID-CA-templates#668`) 行为一致

## 2026-05-10

- 首次发布
