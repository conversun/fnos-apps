# CoolerControl for fnOS

CoolerControl 是 Linux 上的风扇、温度传感器、水冷与散热设备监控/控制系统。本 fnOS 包使用官方 Docker 镜像 `coolercontrol/coolercontrold`，Web UI 默认端口为 `11987`。

## 注意事项

- CoolerControl 依赖主机硬件传感器和 PWM 控制接口，需要访问 `/sys/class/hwmon`、`/dev/i2c-*`、`/dev/hidraw*` 等设备，因此容器以 `privileged` 模式运行。
- 实际可控设备完全取决于 NAS 主板、内核驱动和硬件是否暴露可写 PWM 控制。很多低功耗 NAS/迷你主机只暴露温度或转速读数，不一定能调速。
- 如果 UI 中能看到传感器但无法控制风扇，请确认内核模块、BIOS 风扇设置、I2C/hwmon 驱动是否支持写入。
- 配置持久化在 fnOS 应用数据目录的 `config` 子目录，并挂载到容器内 `/etc/coolercontrol`。

## Local Build

```bash
cd apps/coolercontrol && ./update_coolercontrol.sh
```
