# 下载后就开始玩

1. [下载游戏](https://github.com/coattail/kof10-mac/releases/latest/download/KOF10Mac-AppleSilicon.zip)，解压。
2. 双击“拳皇十周年 Mac.app”。首次自动准备，完成后直接打开模拟器主窗口，不显示额外的版本选择。
3. 在模拟器中选择 **File → Load game**，双击想玩的游戏。
4. 按 **2 投币 → 1 开始**，用 **WASD 移动，J K U I 攻击**。

可直接在下载目录运行。想保留在应用程序列表中，再拖入“应用程序”即可；搬动应用不会丢失个人存档。

## 第一次打不开

应用尚未获得 Apple Developer ID 签名和公证，macOS 可能阻止首次打开。确认是从本项目下载后：尝试打开一次，再到 **系统设置 → 隐私与安全性 → 仍要打开 → 打开**。以后直接双击。无需关闭整体安全保护或输入终端命令。[Apple 官方说明](https://support.apple.com/en-us/102445)

若提示“会损坏电脑”、恶意内容或文件损坏，请停止并反馈，重新确认下载来源与完整性。

## 第一次准备

自动下载约 185 MB 的兼容组件并校验完整性，会显示百分比；下载和初始化结束后自动打开模拟器。失败时点“重试”，无需自己安装 Wine。之后使用本地缓存，可以离线玩。

若提示需要 Rosetta，点击启动器的“打开 Apple 安装窗口”，按 Apple 的系统提示完成安装，启动器会自动继续。该引导尚未在没有 Rosetta 的 Mac 上实测；若系统安装窗口无法打开，参见 [Apple 安装说明](https://support.apple.com/en-us/102527)。应用不会代替你同意软件许可。

仅支持 Apple Silicon（M 系列），启动器最低要求 macOS 11.0，实际游戏验证为 macOS 27.0.1，没有 macOS 28 最低版本要求。

## 默认操作

| 功能 | 玩家 1 | 玩家 2 |
|---|---|---|
| 方向 | W / S / A / D | 方向键 |
| A / B / C / D | J / K / U / I | 小键盘 1 / 2 / 4 / 5 |
| 开始 | 1 | 3 |
| 投币 | 2 | 4 |

实际映射由导入的每款游戏 INI 决定。Game → Redefine keys 可以调整。

- Enter：暂停或继续。
- Option + Enter：切换全屏（未完整验证）。
- 拖动窗口边缘或角落：连续缩放，画面保持 4:3。
- 选择或切换游戏：File → Load game。
- 点击 Dock 中应用的地球图标：返回模拟器，不弹出额外选择窗口。
- F1 重置，F5 保存，F7 读取；Mac 功能键可能需要 Fn。
- Option + C：金手指。

## GP2040-CE 控制器

目前 D-Input 模式下攻击键与方向键无法录入的问题仍未解决。不能把本包当作已验证的手柄支持版本。

可尝试控制器自带 Keyboard 模式：拔掉 USB，按住 R2 / RT / K3 再插入 USB，然后松开。在默认固件中这是键盘模式；若自定义过启动模式，要以自身配置为准。重新进入按键设置，点击对应输入框后按控制器的键。此路径尚待实体控制器实测确认。[GP2040-CE 官方说明](https://gp2040-ce.info/usage/#input-modes)

## 存档与排错

- 运行时缓存：`~/Library/Application Support/KOF10Mac/Runtime/11.0_1`
- 游戏环境：`~/Library/Application Support/KOF10Mac/Prefix/drive_c/KOF`
- SAVES：即时存档；EEPROM：游戏设置；INI：游戏按键配置。
- 日志：`~/Library/Logs/KOF10Mac/game.log`
- 退出模拟器优先使用 File → Exit，保存设置。

更新或重装应用不会自动清空上述个人环境。迁移兼容组件时保留每款游戏设置。
