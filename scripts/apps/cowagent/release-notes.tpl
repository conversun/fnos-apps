自动构建的 fnOS 安装包

- 基于 [CowAgent v${VERSION}](https://github.com/zhayujie/chatgpt-on-wechat/releases/tag/v${VERSION})
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 默认数据目录: `${TRIM_PKGVAR}/data`

**首次使用**:
1. 访问 `http://your-nas-ip:${DEFAULT_PORT}/chat` 打开 CowAgent Web 界面
2. 首次启动需要配置 LLM API 密钥（OpenAI/Claude/DeepSeek 等）
3. 支持接入微信、飞书、钉钉等多种渠道

${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
