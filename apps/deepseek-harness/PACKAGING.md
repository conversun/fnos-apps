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

空间需求不能按约 222 MiB 的压缩包估算。x86 包实际包含约 9.4 万个普通文件，
逻辑内容约 0.94 GiB；在本次 fnOS 测试卷的 ext4 bigalloc、64 KiB 簇上，
仅普通文件的分配下限就约为 6.2 GiB，另有约 6500 个目录。
fnOS 会同时保留解压目录与安装目标，估算峰值约 14 GiB，建议目标卷预留
至少 16 GiB 可用空间。本次仅剩约 9.4 GiB 的测试卷在复制阶段实际耗尽可用
字节，返回 `10233` / `ENOSPC` 并回滚；失败时仍有约 12.9 万个可用 inode，
与 Node/Bun、API Key 或端口冲突无关。该数字来自 x86 包和实际文件系统，
其他包或分配粒度应另行估算。
