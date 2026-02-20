# AdGuardHome for fnOS

网络范围的广告和跟踪器拦截 DNS 服务器。

> **注意**: 端口 53 可能与系统 DNS 服务 (systemd-resolved) 冲突，如遇问题请先停止系统 DNS 服务。

## Local Build

```bash
cd apps/adguardhome && bash ../../scripts/build-fpk.sh . app.tgz
```
