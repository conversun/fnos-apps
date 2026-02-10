## 2026-02-10

- ⚠️ 改为以 `nginxserver` 用户运行（非 root），提升安全性
- 升级时自动修正数据目录权限，无需手动操作
- 修复启动时 `could not open error log file` 错误
