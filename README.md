# 拳皇十周年 Mac

## [⬇️ 下载游戏（Apple Silicon Mac）](https://github.com/coattail/kof10-mac/releases/latest/download/KOF10Mac-AppleSilicon.zip)

**解压 → 双击“拳皇十周年 Mac” → 自动进入拳皇 2002。**

第一次打开会自动联网准备，窗口会显示进度，完成后直接进入游戏。以后双击即可进入，不用找 ROM、不用设置模拟器，也不用在英文菜单里载入游戏。可直接从下载目录运行；想长期保留，再拖入“应用程序”即可。

**开始玩：按 `2` 投币，按 `1` 开始；`W A S D` 移动，`J K U I` 攻击。**

想换拳皇 97、98 等版本，点击 Dock 中“拳皇十周年 Mac”的地球图标，在中文窗口中点选。下次打开会记住这里选的版本。保留模拟器原有按键设置、存档、金手指和 4:3 连续缩放。

> 首次打开若被 macOS 拦住：先尝试打开一次，再到“系统设置 → 隐私与安全性 → 仍要打开”。当前应用尚未获 Apple 签名与公证，这一步暂时不能省略。只需为此应用操作，无需关闭整体安全保护。[打不开时的说明](docs/INSTALL.md)

包含拳皇 94、95、96、97、98、99、2000、2001、2002、2003。适用于 **M 系列芯片的 Mac**，需要 Rosetta；没有 Rosetta 时，启动器会引导打开 Apple 安装窗口。初次准备需要网络（自动下载约 185 MB），完成后可离线玩。最低部署目标 macOS 11.0，实际验证环境为 macOS 27.0.1；Intel Mac 和其他系统版本未逐项验证。

[详细操作说明](docs/INSTALL.md) · [已知问题](docs/COMPATIBILITY.md) · [下载版本说明](https://github.com/coattail/kof10-mac/releases/latest)

GP2040-CE 的 D-Input 按键录入仍有未解决的问题。其他型号手柄、双人、联机和全部 ROM 未逐项验证。

<details>
<summary>开发者：源码与构建</summary>

本项目包含 Apple Silicon 原生启动器和兼容修复源码。Code → Download ZIP 提供源码；普通玩家请使用上方“下载游戏”。

安装 Xcode Command Line Tools、Python 3、Pillow、MinGW 工具链；准备兼容游戏文件。

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-build.txt
make -C third_party/cnc-ddraw
.venv/bin/python scripts/build.py \
  --game-dir "/path/to/compatible-game" \
  --download-runtime
.venv/bin/python scripts/package.py "dist/拳皇十周年 Mac.app"
```

`--game-dir` 必须包含 `game.exe`、`ROMS/*.zip`、`mfc42.dll`、`msvcp60.dll`、`msvcirt.dll`，以及匹配的 BIOS。原保护壳版本无法运行，构建脚本拒绝已知不兼容文件；见[兼容性说明](docs/COMPATIBILITY.md)。关闭游戏辅助程序使用 MinGW 或 LLVM-MinGW 编译；可通过 `KOF_WINDOWS_CC` 指定编译器路径。

Wine 使用 [Gcenx Wine 11.0_1](https://github.com/Gcenx/macOS_Wine_builds/releases/tag/11.0_1)，由玩家直接从上游下载，固定版本并校验 SHA-256。`--wine-dir` 可替代 `--download-runtime` 用于个人离线构建；再次分发离线包需要单独满足全部运行时依赖许可。

- `src/Launcher.swift`：自动进入游戏、中文选择窗口、进度、重试与 Apple 安装引导。
- `src/launch.sh`：独立游戏环境与兼容配置迁移。
- `src/close-game.c`：按模拟器正常关闭路径切换游戏，保留设置。
- `config/`：应用元数据、4:3 显示配置和 Wine 设置。
- `third_party/cnc-ddraw/`：完整 MIT 显示源码，包含实时缩放修复。
- `scripts/`：构建、ZIP 和校验清单生成。

[发布验证记录](docs/VERIFICATION.md) · [发布步骤](docs/RELEASING.md)

</details>

<details>
<summary>来源与许可</summary>

源码仓库不包含 ROM、BIOS、模拟器、微软运行库、原游戏图标或存档；这些内容单独放在 Release 附件中。发布者已确认原包游戏文件的公开分发授权。MIT 只适用于本项目自有代码，第三方内容的权利不因本仓库许可证而改变。

公共包不再分发 Wine 二进制及其依赖，由玩家本机直接从上游取得。[第三方来源与许可](docs/THIRD_PARTY.md)

</details>
