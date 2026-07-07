# Verysync（微力同步）for fnOS

Verysync 是来自 verysync.com 的闭源免费文件同步工具，提供类似 Syncthing 的 P2P 文件同步能力和 Web 管理界面。

## fnOS 打包说明

- 默认端口：`8666`
- 打包模式：Native（二进制直装）
- 支持架构：x86_64（amd64）与 ARM64（arm64/aarch64）
- 上游来源：`https://www.verysync.com/download.php?platform=linux-amd64` 与 `linux-arm64`

## 本地构建

```bash
cd apps/verysync && ./update_verysync.sh --arch x86
cd apps/verysync && ./update_verysync.sh --arch arm
```

## 许可证说明

Verysync 是闭源免费软件。本仓库仅下载并重新打包官方 Linux 二进制，不修改上游程序本体。
