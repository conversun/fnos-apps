# MSF for fnOS

MSF 是一个面向 MosDNS + Mihomo 工作流的管理面板，提供 DNS 分流、透明代理、Mihomo 配置管理和组件更新能力。

## 运行方式

- WebUI: `http://<fnOS主机IP>:7777`
- 数据目录: fnOS 应用运行目录 `TRIM_PKGVAR`
- 上游项目: <https://github.com/scoltzero/msf>
- 上游启动命令: `msf serve --config <data-dir> --host 0.0.0.0 --port 7777`

## 权限说明

上游 fnOS FPK 文档明确说明 MSF 需要 root 权限，因为初始化后会绑定 MosDNS `:53`，写入 nftables，并管理 `ip rule` / `ip route` 与透明代理相关网络状态。本包保持 native binary 模式，并在 `config/privilege` 中设置 `run-as: root`。

fnOS native 包没有 Docker 的 `NET_ADMIN` / `/dev/net/tun` 声明模型；如某些 TUN/透明代理能力在具体设备上仍受系统策略限制，请优先使用 MSF WebUI 的诊断功能和上游文档排查。

## 图标

应用图标使用 Dashboard Icons 的 Clash 图标（MIT License），契合 Mihomo/Clash.Meta 管理面板场景。
