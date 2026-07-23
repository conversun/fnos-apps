# CloudDrive2 for fnOS

CloudDrive2 是一款多网盘挂载与管理工具，可在本地统一管理和挂载云端存储。

## 使用

- Web 管理界面：`http://<fnOS IP>:19798`
- 默认没有账号和密码；首次打开 Web UI 后，请自行添加并授权云盘账号。
- 云盘挂载点位于容器的 `/CloudNAS`，映射到应用数据目录的 `data` 子目录；配置数据保存在 `config` 子目录。

## 运行要求

CloudDrive2 通过 FUSE 在容器内挂载云盘，并将挂载传播到宿主机。因此安装前请确认：

1. fnOS 主机内核已加载并提供 `/dev/fuse`（需要 FUSE 内核模块）。
2. 容器必须以特权模式运行，并授予 `SYS_ADMIN` 能力；该应用的 Docker 配置已包含这些权限。
3. Docker 服务和 CloudDrive2 数据目录所在的宿主机挂载必须支持共享挂载传播。若挂载失败并提示权限不足，请由系统管理员按 [CloudDrive2 Docker 文档](https://www.clouddrive2.com/docker.html) 配置 Docker 的 `MountFlags=shared`，或对对应宿主机挂载执行 `mount --make-shared`。

上述配置会使容器拥有较高权限，仅应在信任 CloudDrive2 官方镜像时安装。

## 本地构建

```bash
cd apps/clouddrive2
./update_clouddrive2.sh
```
