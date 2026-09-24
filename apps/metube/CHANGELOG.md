## 2026-09-24（二）

- 【加固】镜像引用从滚动 :latest 改为按日期标签固定（2026.09.23 等，#310 后续）
  - 滚动标签上游一坏全部翻车且无法回退；改为构建时把实际日期标签写进 compose，按版本可回退
  - get-latest-version.sh 改为跟踪 Docker Hub 日期标签

## 2026-09-24

- 【修复】安装后无法启动的问题 (issue #310)
  - config/resource 缺少 docker-project 声明，fnOS 不会注册 compose 项目，容器从未被创建
  - 补充 docker-project 与 port-config（MeTube.sc），并新增 L1 静态检查防止同类问题再次发布

## YYYY-MM-DD

- 首次发布
