# Obsidian for fnOS

Obsidian 是一款本地优先的个人知识库与笔记工具。本软件包使用 LinuxServer Docker 镜像，以浏览器方式提供桌面界面。

## 使用说明

- 默认端口：`8080`
- 访问地址：`https://<fnOS-IP>:8080/`
- 数据目录：`/config` 映射到应用数据目录中的 `data/`，用于保存 Obsidian 配置和笔记库。
- 应用不提供内置认证，请仅在受信网络中使用；如需公网访问，请通过具备认证和 TLS 管理能力的反向代理提供访问。
- 容器需要 `1GB` 共享内存（`shm_size: 1gb`），请确保 NAS 有足够可用内存。

## 本地构建

```bash
cd /Users/cyonsun/Documents/Code/FNOS/fnos-apps
./apps/obsidian/update_obsidian.sh
```
