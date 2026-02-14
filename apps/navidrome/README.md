# Navidrome for fnOS

Navidrome 是一个开源的个人音乐流媒体服务器,兼容 Subsonic/Airsonic API,支持多用户管理和移动端应用。

## 特性

- 🎵 支持多种音频格式
- 📱 兼容 Subsonic/Airsonic 客户端
- 👥 多用户支持
- 🎨 现代化 Web 界面
- 📊 播放统计和智能播放列表

## 配置

- 默认端口: 4533
- 音乐文件夹: 安装后在 fnOS 数据共享中配置 Navidrome 共享文件夹
- 数据目录: 自动创建在应用数据目录

## Local Build

```bash
cd apps/navidrome && bash ../../scripts/build-fpk.sh . app.tgz
```
