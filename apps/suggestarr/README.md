# SuggestArr for fnOS

SuggestArr 会根据 Plex、Jellyfin 或 Emby 的观影记录生成相似影视推荐，并自动向 Seerr / Jellyseerr / Overseerr 提交媒体请求。

此 fnOS 包使用官方 Docker 镜像 `ciuse99/suggestarr`，应用配置（TMDb API Key、Seerr/Jellyseerr URL、媒体服务器连接等）在 SuggestArr Web UI 中完成。

## Local Build

```bash
cd apps/suggestarr
./update_suggestarr.sh
```
