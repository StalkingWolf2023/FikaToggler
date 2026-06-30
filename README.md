# FikaToggler

**[中文](#中文) | [English](#english)**

一键切换 SPT / Fika 的「单人模式」与「联机模式」的小工具。
A small GUI tool for switching SPT / Fika between single-player and multiplayer modes with one click.

---

<a id="中文"></a>
## 中文说明

### 这个工具解决什么问题

装上 Fika 之后,塔科夫(SPT)默认会强制走联机流程——哪怕你只是想自己单人刷一把,也得先手动跑服务端、改 IP、确认联机能起来,退出后又得手动把东西改回去。本工具把这套"装上 Fika 之后单人游玩反而变麻烦"的痛点,变成点一下按钮就能切换的三个模式:

- **本地单人**:禁用 Fika 插件/服务端模组文件,把连接地址重置为 `127.0.0.1`。
- **联机·主机**:启用 Fika 文件,把连接地址设为本机的虚拟局域网 IP,并在本机起服务端。
- **联机·客机**:确保 Fika 已启用,只把连接地址指向主机的虚拟 IP,本机不跑服务端。

工具只负责"切换",不负责"安装"——如果检测不到 Fika 客户端插件或服务端模组,会提示你先去官方/Wiki 完成安装。

### 功能特性

- 自动定位 SPT 服务端目录与客户端目录(支持游戏与服务端分离安装,也支持合并安装在同一目录的布局)
- 通过移动 `BepInEx\plugins\Fika` 与 `user\mods\fika-server` 文件夹实现 Fika 的启用/禁用
- 结构化读写 `http.json` 与 `launcher\config.json`(使用 JSON 解析而非文本替换,避免破坏配置文件结构)
- 切换前自动创建配置快照,保留最近 10 份,支持一键恢复(仅恢复 `http.json` 与 launcher 配置,不涉及 Fika 文件的启用/禁用状态)
- 操作前检测 `SPT.Server.exe` / `SPT.Launcher.exe` / `EscapeFromTarkov.exe` 是否在运行,避免文件被占用导致操作中途失败
- 显示当前环境检测到的版本号(SPT / Fika 插件 / Fika 服务端 / EFT),并列出开发者本人测试通过的版本组合供参考
- 操作日志实时显示在界面上,同时按日期持久化写入 `logs` 目录
- 中文/英文双语界面,简体中文系统默认显示中文,其余系统默认显示英文,可一键切换

### 安装步骤

1. 从 [Releases](../../releases) 页面下载最新版本的 `FikaToggler.ps1` 和 `FikaToggler.bat`。
2. 将两个文件放在**同一个目录**下(建议是一个你自己新建的空文件夹,不要放进游戏目录里)。
3. 双击运行 `FikaToggler.bat`。首次启动可能会有一瞬间的黑色窗口闪烁,这是正常现象。
4. 点击「浏览...」,选择你的塔科夫/SPT 所在的根目录(可以是游戏文件夹本身,也可以是它的上一层文件夹)。
5. 工具会自动扫描并显示检测结果。检测通过后即可选择模式并应用配置。

> 建议在下载后核对一下文件的 SHA256 哈希值,与 Release 页面公布的哈希值是否一致(见下方「校验文件完整性」)。

### 已测试版本组合

本工具开发与测试时使用的版本组合如下,仅供参考,实际兼容性以你的运行效果为准(不同发布渠道的版本号编号方式可能不一致,例如 Fika 服务端 dll 内嵌的版本号与官方 Release 包名版本号并不总是一一对应):

| 组件 | 版本 |
|---|---|
| SPT | 4.0.13 (40087) |
| Fika 客户端插件 | Release 2.3.3 |
| Fika 服务端 | Release 2.3.2 |

### 关于 Windows SmartScreen 警告

由于本工具是个人编写的免费小工具,没有购买代码签名证书,首次运行 `.bat` 或被杀毒软件扫描 `.ps1` 时,Windows 可能会弹出 SmartScreen「发布者未知」或类似的拦截提示。这是所有未签名脚本/exe 都会遇到的正常现象,并不代表文件有问题。

如果你信任这个工具(建议先对照下方的 SHA256 哈希值进行核验),可以点击「更多信息」→「仍要运行」继续。如果不放心,欢迎直接阅读源码——整个工具就是一个单文件的 PowerShell 脚本,所有逻辑都是公开透明的,没有任何网络请求或下载行为。

### 工作原理简述

1. **目录定位**:从你选择的根目录开始,先判断该目录本身是否就是服务端目录(同时存在 `SPT.Server.exe` 和 `user\mods`);如果不是,则向下递归最多 3 层查找。客户端目录的定位类似,但会优先读取服务端 `user\launcher\config.json` 中记录的 `GamePath` 字段,这样即使你的游戏目录和服务端目录是分离安装的,也能正确找到。
2. **启用/禁用 Fika**:在服务端目录下维护一个 `_FikaDisabled` 文件夹,通过整体移动 `BepInEx\plugins\Fika` 和 `user\mods\fika-server` 文件夹进出这个备份目录来实现切换,不会删除任何文件。
3. **修改连接地址**:用 PowerShell 的 `ConvertFrom-Json` / `ConvertTo-Json` 读写 `http.json` 的 `backendIp` 字段和 `launcher\config.json` 的 `Server.Url` 字段,保证不会破坏 JSON 结构或丢失其他配置项。
4. **安全检测**:每次切换或启动前,都会检查 `SPT.Server`、`SPT.Launcher`、`EscapeFromTarkov` 三个进程是否在运行,只要有一个在运行就会阻止操作并提示先关闭,避免文件被占用导致移动失败、配置写入一半等问题。

### 校验文件完整性(可选,但建议)

下载后,可以在 PowerShell 中执行以下命令计算文件哈希,并与 Release 页面公布的值比对:

```powershell
Get-FileHash .\FikaToggler.ps1 -Algorithm SHA256
Get-FileHash .\FikaToggler.bat -Algorithm SHA256
```

### 常见问题

- **为什么恢复快照后 Fika 的启用/禁用状态没变?** 快照只保存 `http.json` 和 launcher 配置这两个连接相关的文件,不涉及 Fika 插件/服务端模组文件的移动状态,这是有意为之——避免恢复操作在你不知情的情况下悄悄改变 Fika 的启用状态。
- **工具能帮我装 Fika 吗?** 不能。这个工具只负责在"已经装好的" Fika 之间切换启用/禁用,安装请参考 [Fika Wiki](https://wiki.project-fika.com)。

### 协议

本项目采用 [MIT License](./LICENSE) 开源。

---

<a id="english"></a>
## English

### What problem this solves

Once Fika is installed, SPT defaults to a multiplayer-first workflow — even if you just want to play solo, you have to manually start the server, fix up IP addresses, confirm everything connects, and then manually revert it all afterward when you're done. FikaToggler turns that "installing Fika makes solo play more annoying" problem into a one-click switch between three modes:

- **Single Player**: disables the Fika plugin/server mod files and resets the connection address to `127.0.0.1`.
- **Multiplayer - Host**: enables the Fika files, sets the connection address to your machine's virtual LAN IP, and runs the server locally.
- **Multiplayer - Guest**: ensures Fika is enabled, but only points the connection address at the host's virtual IP — no local server is started.

The tool only handles *switching*, not *installing*. If it can't detect the Fika client plugin or server mod, it will point you to the official site/wiki to install them first.

### Features

- Automatically locates the SPT server and client root folders (supports both split installs and combined game+server installs)
- Toggles Fika on/off by moving the `BepInEx\plugins\Fika` and `user\mods\fika-server` folders
- Reads/writes `http.json` and `launcher\config.json` using structured JSON parsing rather than text replacement, so the file structure is never corrupted
- Creates a configuration snapshot before every switch (keeps the last 10), with one-click restore (restores only `http.json` and the launcher config — Fika's enabled/disabled state is intentionally not touched by restore)
- Checks whether `SPT.Server.exe` / `SPT.Launcher.exe` / `EscapeFromTarkov.exe` are running before any operation, to avoid file-lock failures or half-written configs
- Displays the detected version numbers for SPT / Fika plugin / Fika server / EFT, alongside the version combination the developer personally tested
- Live log output in the GUI, also persisted to disk daily under `logs`
- Bilingual Chinese/English UI — defaults to Chinese on Simplified Chinese systems, English elsewhere, switchable anytime

### Installation

1. Download the latest `FikaToggler.ps1` and `FikaToggler.bat` from the [Releases](../../releases) page.
2. Put both files in the **same folder** (preferably a new empty folder you create yourself — not inside your game directory).
3. Double-click `FikaToggler.bat` to run it. A brief black console flash on first launch is normal.
4. Click "Browse..." and select the root of your Tarkov/SPT installation (this can be the game folder itself or its parent folder).
5. The tool scans automatically and shows the detection results. Once detection succeeds, pick a mode and apply.

> It's a good idea to verify the SHA256 hash of the downloaded files against the values published on the Release page (see "Verifying file integrity" below).

### Tested version combination

This is the combination the tool was developed and tested against. It's for reference only — actual compatibility depends on your own setup (version numbering can differ across release channels; for example, the Fika server dll's embedded version doesn't always match the official Release tag name):

| Component | Version |
|---|---|
| SPT | 4.0.13 (40087) |
| Fika client plugin | Release 2.3.3 |
| Fika server | Release 2.3.2 |

### About the Windows SmartScreen warning

Since this is a free tool made by an individual without a code-signing certificate, Windows may show a SmartScreen "unknown publisher" warning the first time you run the `.bat`, or your antivirus may flag the `.ps1`. This is normal for any unsigned script or executable and doesn't mean anything is wrong with the file.

If you trust the tool (ideally after verifying the SHA256 hash below), click "More info" → "Run anyway" to proceed. If you'd rather verify it yourself, the entire tool is a single PowerShell script — all logic is plainly visible in the source, and it makes no network requests or downloads of any kind.

### How it works

1. **Folder detection**: starting from the folder you select, it first checks whether that folder itself is the server root (containing both `SPT.Server.exe` and `user\mods`); if not, it recurses up to 3 levels deep. Client folder detection works similarly, but first checks the `GamePath` field recorded in the server's `user\launcher\config.json`, so split installs (game and server in different locations) are still found correctly.
2. **Enabling/disabling Fika**: a `_FikaDisabled` folder is maintained under the server root, and the `BepInEx\plugins\Fika` and `user\mods\fika-server` folders are moved into/out of it as whole units — nothing is ever deleted.
3. **Changing connection addresses**: PowerShell's `ConvertFrom-Json` / `ConvertTo-Json` are used to read and write the `backendIp` field in `http.json` and the `Server.Url` field in `launcher\config.json`, so the JSON structure and any other settings are preserved.
4. **Safety checks**: before every switch or launch, the tool checks whether `SPT.Server`, `SPT.Launcher`, or `EscapeFromTarkov` are running. If any of them are, the operation is blocked and you're prompted to close them first, to avoid file-lock failures or partially-written configs.

### Verifying file integrity (optional, but recommended)

After downloading, you can compute the file hashes in PowerShell and compare them against the values published on the Release page:

```powershell
Get-FileHash .\FikaToggler.ps1 -Algorithm SHA256
Get-FileHash .\FikaToggler.bat -Algorithm SHA256
```

### FAQ

- **Why doesn't restoring a snapshot change Fika's enabled/disabled state?** Snapshots only cover `http.json` and the launcher config (the connection-related files), not the Fika plugin/server mod file move state. This is intentional, so a restore can never silently change whether Fika is enabled without your knowledge.
- **Can this tool install Fika for me?** No. It only toggles an *already installed* Fika setup on or off. For installation, see the [Fika Wiki](https://wiki.project-fika.com).

### License

This project is licensed under the [MIT License](./LICENSE).
