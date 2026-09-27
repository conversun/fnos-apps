# Blinko for fnOS

[Blinko](https://github.com/blinko-space/blinko) — 自托管笔记与速记应用(Markdown / 双链 / 标签 / 全文搜索 / AI 整理)。

- **模式**:Docker(blinko + PostgreSQL 14)
- **默认端口**:1111(安装后可在应用设置中修改)
- **数据**:`${TRIM_PKGVAR}` 下的 `data/`(笔记附件)与 `postgres/`(数据库),升级保留
- **版本跟踪**:Docker Hub `blinkospace/blinko` 版本标签

首次启动需初始化数据库,Web 页面可能要等 30–60 秒才就绪。
