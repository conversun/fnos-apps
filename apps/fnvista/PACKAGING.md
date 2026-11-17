# 飞牛视野 FnVista：1.0.1-r1 本地生命周期适配

上游为 mclhm8182/FnVista v1.0.1，应用标识仍为
`fnos-bing-wallpaper`。本地版本 `1.0.1-r1` 修复标准卸载后遗留的两张
webp 和前端 CSS/JS 注入；上游 1.0.1 在 fnOS 1.2.0505 的实际卸载
返回成功，但完整文件比较确认这三项未恢复。手工还原不属于上游卸载成功。

## 保留边界

- 原始 `app.tgz` 整个压缩文件逐字节保留，不解包重建，不修改应用代码。
  manifest 中的原始 MD5 checksum 因此保持不变，`platform=all` 保持不变。
- 原始图标、权限、资源配置、安装/升级/配置/主入口及所有向导保持原样。
- 原始 `cmd/uninstall_callback` 原样改名为 `cmd/uninstall_upstream`。
  仅增加本地卸载入口、进程静止辅助脚本和 MIT LICENSE，修改 manifest 版本。
- 不加入未使用的 shared `common`、`installer`，不修改通用 L2 检查。

## 构建与版本

```bash
OUTPUT_DIR=/absolute/output bash apps/fnvista/update_fnvista.sh --arch x86 v1.0.1
OUTPUT_DIR=/absolute/output bash apps/fnvista/update_fnvista.sh --arch arm 1.0.1-r1
# 同一个构建入口，也可直接调用：
ARCH=x86 VERSION=1.0.1-r1 OUTPUT_DIR=/absolute/output \
  bash scripts/apps/fnvista/build.sh
```

两个输出都含原始通用载荷，仅文件名区分 x86/arm。
`FNVISTA_VERSION` 也可选择本地版本；`latest` 表示最新已审核本地版本，
不自动追踪未审核的新上游。resolver 接受 `1.0.1`、`v1.0.1`、
`1.0.1-r1`、`v1.0.1-r1`，均解析为 `1.0.1-r1`。
新上游需要重新审核生命周期后更新 `meta.env`，避免把旧适配器盲目套用。

默认下载官方 FPK，并核对固定 SHA256：
`1e9fb621c5deb50bb9bda13b85625956b4de40ac5e8f142123e115a0b2dab65d`。
离线验证可用 `FNVISTA_UPSTREAM_FPK=/absolute/FnVista-1.0.1.fpk`，
仍强制相同 checksum。`TMPDIR` 可指定自己的临时根，构建退出自动删除工作目录。

`BUILD_OUTPUT=fpk` 声明构建脚本直接生成完整 FPK。复用 CI 将输出目录设为
工作目录并传入目标架构，保留本包的卸载适配器，不再调用 shared 打包器覆盖
上游控制文件。其他应用仍按原有官方直通或 `app.tgz` 路径构建。

## 卸载次序

fnOS 在卸载回调前以 `TRIM_APP_STATUS=UNINSTALL` 调用 `main stop`。
上游的 stop 会无条件还原并删除自定义壁纸，导致向导选择保留也无效。
本包在此阶段只停止应用写入，把是否还原交给卸载回调；其他 main 操作仍执行
字节不变的上游入口，普通停用保留上游行为。

1. 把已部署 CGI 重命名为 `index.cgi.fnvista-uninstall`，不修改字节，
   阻止旧页面发起新请求。仅 chmod 对 root 解释器不足以阻止读取。
   删除应用 cron；精确匹配应用脚本路径，暂停所有应用写入进程及子进程，
   闭合进程树后终止并等待退出。不杀 nginx、cron 服务或其他应用。
   随后再次删除可能被在途 cron-update 重建的应用 cron。
2. 调用原始卸载钩子，保留其数据库、用户自定义图片和部署脚本清理行为。
3. `wizard_restore=true`（含上游认可的真值，未设置时默认 true）时，
   解锁两张 webp，从 `/var/lib/fnos-wallpaper/orig/` 直接复制
   `wallpaper-1.webp.orig` 和 `thumb-1.webp.orig`，不转码。
   缺备份、写入或解锁失败会明确返回非零。
4. 无论是否恢复壁纸，只移除准确的
   `<style id="fnos-bing-wp-css">...</style>` 和
   `<script id="fnos-bing-wp-js">...</script>` 字节块。
   同时清理 live `index.html` 和 `www.zip` 的 `index.html` 条目，
   防止系统从还原源重新注入；其他 HTML 字节不变。
   `wizard_restore=false` 不复制 webp、不调用额外数据库恢复。

原上游 stop 会调用恢复，不在本次修复范围内。测试 false 时不要预先 stop，
应记录 fnOS 实际卸载是否额外调用 stop。
照片、缓存、原始备份和日志沿用上游保留策略。
失败卸载撤下的 CGI 需要重新安装后再打开 UI。
依赖 bash、Python 3、ps、zip/unzip、chattr（存在时使用），应用原有依赖仍有效。

## 验证与主执行者 VM 命令

本地检查：

```bash
bash scripts/test/static-check.sh fnvista
bash scripts/test/verify-fpk.sh /absolute/output/fnos-bing-wallpaper_1.0.1-r1_x86.fpk
bash scripts/test/verify-fpk.sh /absolute/output/fnos-bing-wallpaper_1.0.1-r1_arm.fpk
bash scripts/apps/fnvista/verify-repair.sh /absolute/FnVista-1.0.1.fpk /absolute/output
```

通用 L2 仍因上游不使用 `cmd/common`、`cmd/installer` 返回非零；
不添加空文件规避。专用检查覆盖原始载荷/控制文件、MD5、版本、通用平台、
两种文件名、HTML 字节删除和进程树终止。主执行者负责真实 VM QA；
本次未访问 VM，也未声称浏览器、数据库或系统守护进程已通过实际验收。

在主执行者已有 baseline/1379 文件快照和可恢复测试床上，分别全新安装本次
x86 包、打开 CGI、实际换壁纸并开启轮播。先不要关闭旧页面，以覆盖旧 iframe
和后台作业。确认版本为 `1.0.1-r1`，应用 identity 不变。
每次均使用同一份安装前数据库偏好和系统文件快照作为独立预期。

```bash
# VM 上：记录安装前 3 个文件，并另存 DB 偏好和完整 www 快照。
sha256sum /usr/trim/www/index.html \
  /usr/trim/www/static/bg/wallpaper-1.webp \
  /usr/trim/www/static/thumbnail_bg/wallpaper-1.webp

# 卸载向导选择恢复后，或已停止服务以外的单独 hook 诊断：
sudo env TRIM_APPDEST=/var/apps/fnos-bing-wallpaper/target \
  TRIM_APPNAME=fnos-bing-wallpaper wizard_restore=true \
  bash /var/apps/fnos-bing-wallpaper/cmd/uninstall_callback

# 在独立重新安装、重新应用壁纸的周期，选择不恢复；不要先执行 stop：
sudo env TRIM_APPDEST=/var/apps/fnos-bing-wallpaper/target \
  TRIM_APPNAME=fnos-bing-wallpaper wizard_restore=false \
  bash /var/apps/fnos-bing-wallpaper/cmd/uninstall_callback

# 每个周期最后检查：
ps -eo pid,ppid,args | grep -E 'fnos-wallpaper|bing-wallpaper|fnos-www-zip|fnos-survival|fnos-cron-update|fnos-bing-wallpaper'
test ! -e /etc/cron.d/fnos-bing-wallpaper
sha256sum /usr/trim/www/index.html \
  /usr/trim/www/static/bg/wallpaper-1.webp \
  /usr/trim/www/static/thumbnail_bg/wallpaper-1.webp
unzip -p /usr/trim/share/.restore/www.zip index.html |
  grep -E 'fnos-bing-wp-(css|js)'
```

上面的直接 hook 命令只是诊断路径，不能替代应用中心真实卸载。
真实卸载用应用中心向导，分别选 true/false，并保存其命令输出和退出状态。
true：两张 webp 和 HTML SHA 应与安装前精确一致，DB 偏好一致，完整
1379 文件比较无非预期差异。false：两张 webp/当前 DB 偏好应与卸载前
“已应用”快照一致，HTML 与 zip 中不再含两个注入块，照片/缓存仍在。
两种场景都应无残留应用进程/cron/部署脚本，旧 iframe 请求应失败。
继续观察至少两个 cron 周期并重新读取 live HTML 和 zip；
在 fnOS 完整性守护重建后仍应无重新注入。系统可能因 webp 变化重启
trim_nginx，记录重连而不要将之误认为卸载清理失败。
最后按工作区规则关闭 VM。ARM 运行时仍需真实 ARM fnOS，x86 VM 不覆盖。
