## 2026-09-28

- 【新增】下载目录与网络模式纳入安装/应用设置向导,升级不再丢失(#290)
  - 根因:在飞牛 Docker 设置里改的存储映射/网络模式存在 app center 容器配置里,升级会按包内 compose 重建容器,改动即被覆盖
  - 修复:compose 引用 ${wizard_downloads_dir}/${wizard_network_mode},由飞牛在创建容器时替换向导答案——实测带参升级、无参升级(自动复用已存答案)、设置变更全部生效;嵌套默认值回落应用数据目录
  - Web 端口机制不变(TRIM_SERVICE_PORT + 向导改口,升级重放)

## 2026-07-07

- 【修复】安装时镜像拉取失败问题 (issue #179)
  - 上游 linuxserver 会清理旧的按版本标签（如 `4.1.2-r0-ls350`），导致硬编码该标签的安装包拉取失败
  - docker-compose 改为固定跟踪滚动 `:latest` 标签，避免标签被清理后再次失效
  - get-latest-version.sh 版本号改为日期戳格式，准确反映滚动更新特性

## YYYY-MM-DD

- 首次发布
