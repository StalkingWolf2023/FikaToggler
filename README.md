# FikaToggler

本项目单纯是因为我用 Fika 跟朋友联机当主机,朋友下线之后我还想继续单刷,结果每次开局都得走一遍主持战局的流程,有点蛋疼。
所以写了这么个东西(大部分是 AI 写的),自动处理单人模式、Fika 主机模式、Fika 客机模式之间的切换。
如果你也有类似需求,不妨试一试。

[Read this in English ↓](#english)

## 三个模式

- **本地单人**:把 Fika 插件和服务端模组挪到独立的文件夹中以禁用 Fika 插件,连接地址改回默认 `127.0.0.1`。
- **联机·主机**:把 Fika 文件放回去,地址改成你的虚拟局域网 IP,本机起服务端。
- **联机·客机**:确保 Fika 是启用的,地址指向主机的虚拟 IP,自己不起服务端。

本工具只能"切换",不负责"安装"。没装 Fika 的话它会告诉你去 Wiki 看安装教程,所以请自行安装 Fika 插件。

## 装了之后还有这些

- 能自己找到 SPT 服务端和客户端目录,游戏和服务端分开装、合在一起装都认得出来
- 切换靠的是整体挪文件夹(`BepInEx\plugins\Fika` 和 `user\mods\fika-server`),不是删文件,所以理论上不会丢东西
- 改 `http.json` 和 `launcher\config.json` 用的是正经 JSON 解析,不是文本替换,不会把配置文件改坏
- 每次切换前自动存一份本地快照,留最近 10 份,提供历史记录恢复功能(只恢复连接地址相关的两个文件,Fika 启用状态不受影响,这个是故意的)
- 操作前会监测 SPT 服务端、启动器、游戏本体是不是在运行,检测到运行状态会提示警告,不然文件被占着移动会出问题
- 界面上能看到当前环境检测到的版本号,也放了我自己测试通过的版本组合,仅供参考
- 中英文界面,简中系统默认中文,其他默认英文

## 怎么用

1. 去 [Releases](../../releases) 下最新的 `FikaToggler.ps1` 和 `FikaToggler.bat`,**两个文件请放一起,不限制目录**。
2. 双击 `.bat` 运行以调用 PS 脚本。第一次启动可能闪一下黑窗口,正常的。
3. 点「浏览」,选你塔科夫游戏所在的根目录,游戏文件夹本身或者它的上一层都行(这是 AI 说的,我建议你直接选游戏根目录文件夹)。
4. 工具会自动扫一遍,扫完了选模式、点应用就行。

## 我的测试环境

测试环境:Win11

| 组件 | 版本 |
|---|---|
| SPT | 4.0.13 (40087) |
| Fika 客户端插件 | Release 2.3.3 |
| Fika 服务端 | Release 2.3.2 |

不同渠道的版本号有时候对不上(比如 Fika 服务端 dll 里写的版本号,跟官方 Release 包名不一定一致),这个表格中的版本以相关 GitHub 发布页名称为准,我是直接 copy 的。

## Windows 弹 SmartScreen 警告怎么办

个人手搓小工具,没钱买代码签名证书,所以第一次跑报错、或者杀软报毒很正常,请自行斟酌选用。

我都没打包,Bro 可以直接看源码。

## 几个实现细节

- **找目录**:从选的文件夹开始,先看是不是服务端目录(`SPT.Server.exe` 和 `user\mods` 都在就算);不是的话往下翻最多 3 层。客户端目录类似,但会先去读服务端 `user\launcher\config.json` 里记的 `GamePath`,这样哪怕游戏和服务端分开装在不同地方,也能对上。(我只提需求,实现逻辑靠的是 AI)
- **切换 Fika 开关**:服务端目录下会有个 `_FikaDisabled` 文件夹当临时仓库,插件和服务端模组就在这儿和原位置之间搬来搬去,不会被删除。
- **改连接地址**:用 PowerShell 自带的 JSON 解析读写,不会把配置文件结构搞坏。
- **跑之前先检查**:`SPT.Server`、`SPT.Launcher`、`EscapeFromTarkov` 这三个进程只要有一个仍然占用,就先拦下来提示你关掉。

## 想核对文件完整性

请自行算哈希以核对,懒得查命令的话直接抄:

```powershell
Get-FileHash .\FikaToggler.ps1 -Algorithm SHA256
Get-FileHash .\FikaToggler.bat -Algorithm SHA256
```

跟 Release 页面写的、或者 GitHub 自动算出来的对一下就行。

## 常见问题

**恢复快照之后 Fika 怎么还是原来的启用/禁用状态?**
故意的。快照只管连接地址那两个文件,不碰 Fika 插件/服务端模组的移动状态,免得你恢复个快照,结果 Fika 状态被悄悄改了都不知道。

**能帮我装 Fika 吗?**
不能,这工具只在"已经装好"的 Fika 之间切换。装 Fika 请去 [Fika Wiki](https://wiki.project-fika.com)。

## 协议

[MIT License](./LICENSE)。

---

<a id="english"></a>
## English

Built this because I use Fika to host games with a friend — when they log off and I want to keep playing solo, I'd have to go through the whole host setup again just for single-player. Annoying enough that I wrote (well, mostly AI wrote it, I just specified what I wanted) a tool with three buttons: **Single Player**, **Multiplayer Host**, **Multiplayer Guest**. It only switches an *already installed* Fika setup on/off and fixes up the connection addresses — it won't install Fika for you.

**Get it:** grab `FikaToggler.ps1` and `FikaToggler.bat` from [Releases](../../releases), keep them in the same folder (location doesn't matter), double-click the `.bat`. A brief console flash on first run is normal. Browse to your Tarkov root, let it scan, pick a mode, apply.

**What it does under the hood:** toggles Fika by moving `BepInEx\plugins\Fika` and `user\mods\fika-server` in and out of a backup folder (nothing's deleted), rewrites `http.json` / `launcher\config.json` via JSON parsing (not regex, won't corrupt the file), snapshots your config before every switch (last 10 kept; restore brings back the connection settings only — Fika's on/off state is left alone on purpose), and checks that `SPT.Server` / `SPT.Launcher` / `EscapeFromTarkov` aren't running before touching anything.

Tested on Win11 with SPT 4.0.13 (40087), Fika plugin 2.3.3, Fika server 2.3.2 — version numbers taken straight from the respective GitHub release pages, no guarantee for other combos.

No code signing certificate, so SmartScreen will probably complain on first run, or your antivirus might flag it — that's normal for any unsigned script, use your own judgment. It's a single unpackaged `.ps1`, read the source yourself if you want to be sure. To verify the download:

```powershell
Get-FileHash .\FikaToggler.ps1 -Algorithm SHA256
Get-FileHash .\FikaToggler.bat -Algorithm SHA256
```

and compare against the Release page.

Licensed under [MIT](./LICENSE).
