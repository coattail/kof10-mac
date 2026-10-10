# 第三方来源与许可

| 组件 | 来源 | 许可与发布范围 |
|---|---|---|
| 本项目启动器与打包脚本 | 本仓库 | MIT，见根目录 LICENSE |
| cnc-ddraw 7.1 | https://github.com/FunkyFr3sh/cnc-ddraw/tree/v7.1.0.0 | MIT，完整源码、原版权声明和本地缩放修改位于 third_party/cnc-ddraw |
| Wine 11.0_1 macOS 运行包 | https://github.com/Gcenx/macOS_Wine_builds/releases/tag/11.0_1 | Wine LGPL-2.1；依赖有各自许可，公共 Git 仓库不包含运行时二进制 |
| Wine macOS 依赖与构建配方 | https://github.com/Gcenx/macports-wine | 以对应上游许可和构建配方为准 |
| 微软 VC6 依赖 | https://download.microsoft.com/download/vc60pro/Update/2/W9XNT4/EN-US/VC6RedistSetup_deu.exe | 微软许可；由构建者单独提供，不作为本项目 MIT 文件 |
| Kawaks、游戏 ROM、BIOS、原图标、游戏预设文件 | 用户本地游戏目录 | 第三方文件，须分别具有适用的使用与分发权限，公共 Git 仓库不包含这些文件 |

本项目的 MIT 许可不覆盖游戏 ROM、BIOS、微软文件、Wine 及其依赖或第三方模拟器。发布者已确认原包游戏文件的公开分发授权。公共 Release 包不附带 Wine 及其依赖，由玩家本机直接从上游下载固定版本并保留上游文件。

Wine 的主要源代码见 https://gitlab.winehq.org/wine/wine/-/tree/wine-11.0 。若再分发包含 Wine 及依赖的二进制包，发布者需同时核对实际构建所用补丁与依赖许可，并按适用许可证提供完整对应源码和必要声明；仅附上 Wine 的许可证文本不能代替这些要求。
