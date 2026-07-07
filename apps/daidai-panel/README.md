# Daidai Panel for fnOS

Daidai Panel（呆呆面板）是轻量现代的定时任务与脚本管理面板，采用 Docker 模式打包为 fnOS `.fpk`。

默认宿主机端口为 `5701`，映射到容器内 Web 端口 `5700`。面板数据持久化在 fnOS 应用数据目录下的 `data/`，对应容器路径 `/app/Dumb-Panel`。

## Local Build

```bash
cd apps/daidai-panel && ./update_daidai-panel.sh
```
