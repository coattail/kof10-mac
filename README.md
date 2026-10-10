# 拳皇十周年 Mac / KOF10Mac

把 Windows Kawaks 游戏目录封装成 Apple Silicon Mac 应用的启动器与兼容修复项目。

已在本项目维护者的 Mac 上实际载入拳皇 2002，并由使用者确认可以游玩。窗口可连续缩放，画面保持 4:3，按键、存档和金手指沿用输入的游戏文件。**GP2040-CE 的 D-Input 按键录入仍存在未解决的问题；其他型号手柄、网络联机和全部 ROM 未逐项验证。**

## 下载与安装

[下载版本页面](https://github.com/coattail/kof10-mac/releases) · [安装与操作说明](docs/INSTALL.md) · [已知问题](docs/COMPATIBILITY.md)

目前仓库公开启动器、配置、完整显示组件源码和打包脚本。可运行应用压缩包在本地已准备，游戏文件公开分发授权尚未确认，因此暂未公开包含游戏本体的 Release。仓库的 **Code → Download ZIP 是源码，不是可直接运行的游戏**。

源码不包含商业 ROM、BIOS、模拟器可执行文件、微软运行库、游戏图标或用户存档。构建时从你有权使用的本地目录导入这些文件。此项目的 MIT 许可证只适用于本项目自有代码，第三方文件的许可单独适用。

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
  --wine-dir "/path/to/Wine Stable.app/Contents/Resources/wine"
.venv/bin/python scripts/package.py "dist/拳皇十周年 Mac.app"
```

`--game-dir` 必须包含 `game.exe`、`ROMS/*.zip`、`mfc42.dll`、`msvcp60.dll`、`msvcirt.dll`，以及游戏需要的 BIOS。原 Windows 保护壳版本会崩溃，构建脚本会拒绝已知不兼容的可执行文件；参见[兼容性说明](docs/COMPATIBILITY.md)。

Wine 使用 [Gcenx Wine 11.0_1](https://github.com/Gcenx/macOS_Wine_builds/releases/tag/11.0_1)。通过上游下载和安装，保留其第三方许可。生成的个人应用可直接放入“应用程序”；打包脚本不会自动上传或发布游戏数据。

## 项目结构

- `src/Launcher.swift`：原生 Mac 入口、启动进度、日志和退出管理。
- `src/launch.sh`：独立 Wine 环境、初始化与兼容配置迁移。
- `config/`：应用元数据、GDI/4:3 配置和 Wine 设置。
- `third_party/cnc-ddraw/`：完整 MIT 显示组件源码，包含本项目的实时缩放修复。
- `scripts/`：本地构建、下载压缩包和校验清单生成。
- `docs/`：安装、控制器、验证范围与发布步骤。

[第三方来源与许可](docs/THIRD_PARTY.md) · [发布步骤](docs/RELEASING.md)
