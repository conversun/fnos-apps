DeepSeek Harness 官方 fnOS 安装包直通发布

- 直接采用 [techysy/deepseek-harness-fnos](https://github.com/techysy/deepseek-harness-fnos) 的 iframe 离线包，字节一致，保留上游生命周期与网关集成。
- 支持 x86 和 ARM，应用标识为 dsh；桌面通过 /app/dsh/ 打开，直连端口 ${DEFAULT_PORT}，管理面板端口 28001。
- 依赖 nodejs_v24 和 bunjs；ARM 原生模块要求 glibc ≥ 2.28。
- 工作空间位于共享目录 dsh/dsh_home；凭据保存在应用私有数据区。使用模型需自行配置 API Key。
- 上游打包仓库采用 MIT 许可；包内包含上游构建及运行时补丁，本仓库不再修改。

${CHANGELOG}

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
