## 2026-09-24

- 【修复】安装后无法启动的问题 (issue #310)
  - config/resource 缺少 docker-project 声明，fnOS 不会注册 compose 项目，容器从未被创建
  - 补充 docker-project 与 port-config（MeTube.sc），并新增 L1 静态检查防止同类问题再次发布

## YYYY-MM-DD

- 首次发布
