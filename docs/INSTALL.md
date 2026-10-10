# 安装与游玩

仓库的源码 ZIP 不包含可运行游戏。完整应用 Release 尚待游戏文件公开分发授权确认；当前可自行使用合法取得的游戏目录按照 README 构建。

## 安装 Mac 应用包

1. 从项目 Releases 下载 `KOF10Mac-v1.0.2-AppleSilicon.zip`，并核对同版本 `SHA256SUMS`。
2. 解压，把“拳皇十周年 Mac.app”拖入“应用程序”。
3. 本包使用临时签名，尚未获得 Apple Developer ID 签名或公证。首次打开可能被系统阻止。确认下载来源和校验值后，按照 [Apple 的打开应用说明](https://support.apple.com/en-us/102445)，在“系统设置 → 隐私与安全性”中为此应用选择“仍要打开”。不要关闭系统整体安全保护；若提示应用损坏或包含恶意内容，先停止并反馈。
4. 若启动器提示需要 Rosetta，按照 [Apple 的 Rosetta 安装说明](https://support.apple.com/en-us/102527)安装。应用不会自动接受软件许可。
5. 首次运行会建立独立的游戏环境，需要稍等。在模拟器的 **File → Load game** 中双击游戏版本。

启动器没有 macOS 28 的最低版本要求；最低部署目标为 macOS 11.0。此包仅支持 Apple Silicon，具体系统兼容验证范围见 README。

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
- F1 重置，F5 保存，F7 读取；Mac 功能键可能需要 Fn。
- Option + C：金手指。

## GP2040-CE 控制器

目前 D-Input 模式下攻击键与方向键无法录入的问题仍未解决。不能把本包当作已验证的手柄支持版本。

可尝试控制器自带 Keyboard 模式：拔掉 USB，按住 R2 / RT / K3 再插入 USB，然后松开。在默认固件中这是键盘模式；若自定义过启动模式，要以自身配置为准。重新进入按键设置，点击对应输入框后按控制器的键。此路径尚待实体控制器实测确认。[GP2040-CE 官方说明](https://gp2040-ce.info/usage/#input-modes)

## 存档与排错

- 游戏环境：`~/Library/Application Support/KOF10Mac/Prefix/drive_c/KOF`
- SAVES：即时存档；EEPROM：游戏设置；INI：游戏按键配置。
- 日志：`~/Library/Logs/KOF10Mac/game.log`
- 退出模拟器优先使用 File → Exit，保存设置。

更新或重装应用不会自动清空上述个人环境。迁移兼容组件时保留每款游戏设置。
