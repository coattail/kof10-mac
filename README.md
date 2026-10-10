# 拳皇十周年 Mac / KOF10Mac

把 Windows Kawaks 游戏目录封装成 Apple Silicon Mac 应用的启动器与兼容修复项目。

已在本项目维护者的 Mac 上实际载入拳皇 2002，并由使用者确认可以游玩。窗口可连续缩放，画面保持 4:3，按键、存档和金手指沿用输入的游戏文件。**GP2040-CE 的 D-Input 按键录入仍存在未解决的问题；其他型号手柄、网络联机和全部 ROM 未逐项验证。**

## 下载与安装

[下载版本页面](https://github.com/coattail/kof10-mac/releases) · [安装与操作说明](docs/INSTALL.md) · [已知问题](docs/COMPATIBILITY.md)

在 [Releases](https://github.com/coattail/kof10-mac/releases/latest) 下载 `KOF10Mac-v1.0.2-AppleSilicon.zip`，解压后拖入“应用程序”。下载包包含拳皇 94、95、96、97、98、99、2000、2001、2002、2003 的原包游戏内容。首次启动需要联网，自动从固定上游版本下载约 185 MB 的 Wine 运行时并校验 SHA-256；之后使用本地缓存，不需要再下载运行时。仓库的 **Code → Download ZIP 是源码，不是可直接运行的游戏**。

Git 源码不包含 ROM、BIOS、模拟器可执行文件、微软运行库、游戏图标或存档；游戏内容放在单独的 Release 附件中。发布者已确认原包游戏文件具有公开分发授权。MIT 许可证只适用于本项目自有代码，第三方内容的权利不因本仓库许可证而改变。

## 运行要求

- Apple Silicon Mac（M1/M2/M3/M4 等）。当前启动器仅编译为 arm64；没有提供 Intel Mac 可执行版本。
- 启动器最低部署目标 macOS 11.0；实际游戏验证环境为 macOS 27.0.1。旧系统未逐一验证。
- 需要 Rosetta 运行 x86_64 Wine；根据 [Apple 说明](https://support.apple.com/en-us/102527)，Rosetta 在 macOS 27 及更早版本提供一般兼容，macOS 28 的适用范围会改变。本项目尚未验证 macOS 28。
- 已在 macOS 上兼容的 Kawaks 可执行文件和相匹配的 ROM、BIOS、Visual C++ 6 依赖。

## 本地构建

安装 Xcode Command Line Tools、Python 3、Pillow、可生成 i686 Windows DLL 的 MinGW 工具链；准备游戏与 Wine 运行目录。

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-build.txt
make -C third_party/cnc-ddraw
.venv/bin/python scripts/build.py \
  --game-dir "/path/to/compatible-game" \
  --download-runtime
.venv/bin/python scripts/package.py "dist/拳皇十周年 Mac.app"
```

`--game-dir` 必须包含 `game.exe`、`ROMS/*.zip`、`mfc42.dll`、`msvcp60.dll`、`msvcirt.dll`，以及游戏需要的 BIOS。原 Windows 保护壳版本会崩溃，构建脚本会拒绝已知不兼容的可执行文件；参见[兼容性说明](docs/COMPATIBILITY.md)。

Wine 使用 [Gcenx Wine 11.0_1](https://github.com/Gcenx/macOS_Wine_builds/releases/tag/11.0_1)，由最终玩家直接从上游下载到本机，公共游戏附件不再分发 Wine 二进制或其依赖。`--wine-dir` 可替代 `--download-runtime` 用于个人离线构建，离线包的再次分发需要单独满足全部运行时依赖许可。生成的应用可直接放入“应用程序”；打包脚本不会自动上传数据。

## 项目结构

- `src/Launcher.swift`：原生 Mac 入口、启动进度、日志和退出管理。
- `src/launch.sh`：独立 Wine 环境、初始化与兼容配置迁移。
- `config/`：应用元数据、GDI/4:3 配置和 Wine 设置。
- `third_party/cnc-ddraw/`：完整 MIT 显示组件源码，包含本项目的实时缩放修复。
- `scripts/`：本地构建、下载压缩包和校验清单生成。
- `docs/`：安装、控制器、验证范围与发布步骤。

[第三方来源与许可](docs/THIRD_PARTY.md) · [发布验证记录](docs/VERIFICATION.md) · [发布步骤](docs/RELEASING.md)
