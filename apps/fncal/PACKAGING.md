# FnCal

请求 #361。目录名为 `fncal`，保留上游区分大小写的应用标识及文件前缀 `FnCal`。
CI 和 `bash apps/fncal/update_fncal.sh --arch x86`（或 `--arch arm`）均下载
`FnCal-<版本>.fpk`。上游声明 `platform=all`，两个输出文件内容完全一致。

`fnos/` 仅用于元数据和 L1 检查，不用于重打包；本地 manifest 的 x86 与
UI 端口 5280 用于静态检查。实际 FPK 保留 `platform=all`、`${wizard_port}`、
上游向导、MIT 许可与应用用户 `fncal`。

需要 fnOS ≥ 1.2.0401 和 `nodejs_v22`。默认 HTTP 5280、可选 HTTPS 5243；
安装向导设置账号、密码和端口。0.8.0 以前的版本应按上游说明保留资料卸载后重装。
日历、密钥、账号和设置位于应用私有数据区，升级和保留资料卸载后应核验。

0.8.34 的通用包内 `server/vendor/@napi-rs/canvas/` 只含
`skia.linux-x64-gnu.node`，未含 ARM64 原生模块。保留上游架构声明，不修改包；
ARM 的 MCP 年度总结服务端 PNG 渲染存在上游阻碍，调用方会显式退回 SVG，
不会因该模块缺失阻止服务启动。浏览器端使用自己的 canvas。
不能将下载验证称为 ARM 功能验证。
