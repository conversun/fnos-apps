# DeepSeek Harness

请求 #363。目录名为 `deepseek-harness`，保留上游应用标识和文件前缀 `dsh`。
CI 使用 `scripts/apps/deepseek-harness/meta.env` 下载官方 iframe FPK；本地运行
`bash apps/deepseek-harness/update_deepseek-harness.sh --arch x86` 或 `--arch arm`。

`fnos/` 仅用于应用元数据和 L1 检查，不用于重打包；图标来自官方 FPK。
上游 MIT 许可与其离线依赖、构建期及运行时补丁均保留在原始 FPK 中。
管理面板伴生应用 `dsh-dashboard` 不在本次收录范围。

主端口 28000，管理面板 28001，桌面入口 `/app/dsh/`；需要 `nodejs_v24`、
`bunjs`，ARM 要求 glibc ≥ 2.28。API Key、代理和信任域可在安装向导中配置。
工作空间在共享目录 `dsh/dsh_home`，凭据在私有数据区；卸载后需分别核验。
