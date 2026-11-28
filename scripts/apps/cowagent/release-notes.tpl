自动构建的 fnOS 安装包

- 基于 [CowAgent v${VERSION}](https://github.com/zhayujie/CowAgent/releases/tag/v${VERSION})
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 数据目录: 工作空间 `@appdata/cowagent/cow`（记忆、知识库、Skills、mcp.json），配置与日志 `@appdata/cowagent/cow-data`

**首次使用**:
1. 访问 `http://your-nas-ip:${DEFAULT_PORT}/chat` 打开 CowAgent Web 界面
2. 首次启动需要配置 LLM API 密钥（OpenAI/Claude/DeepSeek 等）
3. 支持接入微信、飞书、钉钉等多种渠道

**从 2.3.0 及更早版本升级**:
旧版安装包把数据目录挂错了位置，控制台里配置的模型、通道和记忆实际保存在容器内部，升级重建容器后不会保留，需要重新配置。如需保留，请在**升级前**通过 SSH 执行（`/vol1` 换成 CowAgent 实际所在的存储空间）：

```bash
sudo docker cp cowagent:/home/agent/cow/. /tmp/cow-backup
sudo docker cp cowagent:/home/agent/.cow/. /tmp/cow-data-backup
```

升级完成后在应用中心停止 CowAgent，再执行下面的命令，然后启动：

```bash
sudo cp -a /tmp/cow-backup/. /vol1/@appdata/cowagent/cow/
sudo cp -a /tmp/cow-data-backup/. /vol1/@appdata/cowagent/cow-data/
```

本版本起数据已持久化到上述目录，以后升级不再丢失（#371）。

${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
