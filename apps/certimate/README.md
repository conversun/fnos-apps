# Certimate for fnOS

Certimate 是一款开源的 SSL/TLS 证书自动化管理工具，支持 ACME 协议自动申请和续签证书。

## 特性

- 支持多种 ACME 服务提供商（Let's Encrypt、ZeroSSL 等）
- 自动续签证书
- 支持多种 DNS 提供商进行域名验证
- Web 管理界面
- 证书部署到多种服务

## 默认配置

- 端口: 8090
- 数据目录: `${TRIM_PKGVAR}/data`

## Local Build

```bash
cd apps/certimate && bash ../../scripts/build-fpk.sh . app.tgz
```
