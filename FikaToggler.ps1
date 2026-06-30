$ErrorActionPreference = "Stop"
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # ===================== 配置区 =====================
    $FikaPluginFolder = "Fika"
    $FikaServerFolder = "fika-server"
    $ConfigFile = Join-Path $PSScriptRoot "fikatoggler.config.json"
    $SnapshotDir = Join-Path $PSScriptRoot "snapshots"
    $LogDir = Join-Path $PSScriptRoot "logs"
    $FikaWiki = "https://wiki.project-fika.com"
    $SptOfficial = "https://sp-tarkov.com"

    $TestedVersions = @{
        SPT        = ": 4.0.13 (40087)"
        FikaPlugin = ": Release 2.3.3"
        FikaServer = ": Release 2.3.2"
    }
    $MaxSnapshots = 10
    # ===================================================

    $script:ServerRoot = $null
    $script:ClientRoot = $null
    $script:BaseFolder = $null
    $script:LogFilePath = $null

    # ---------- 多语言字符串表 ----------
    $Strings = @{
        zh = @{
            form_title              = "SPT / Fika 联机-单机切换工具"
            label_no_folder         = "未选择目录"
            btn_browse               = "浏览..."
            btn_lang_to_en           = "English"
            btn_lang_to_zh           = "中文"
            label_server_root_unknown = "服务端目录：未找到"
            label_client_root_unknown = "客户端目录：未找到"
            label_server_root        = "服务端目录：{0}"
            label_client_root        = "客户端目录：{0}"
            status_unknown            = "状态：未检测"
            status_cannot_detect      = "状态：无法检测"
            status_fika_missing       = "状态：Fika 未安装"
            status_fika_server_missing = "状态：Fika 服务端未安装"
            status_enabled            = "状态：Fika 当前为启用状态（联机可用）"
            status_disabled           = "状态：Fika 当前为禁用状态（单机模式）"
            version_group_title       = "版本信息"
            version_detected_title    = "当前环境（本机检测）："
            version_tested_title      = "已验证可正常工作的环境（开发者测试）："
            version_note              = "注：不同发布渠道的版本号编号方式可能不一致（例如 Fika 服务端 dll 内嵌版本号与官方 Release 包名版本号并不总是一一对应），以上版本信息仅供参考，请以实际运行效果为准。"
            mode_group_title          = "选择模式"
            mode_single                = "本地单人"
            mode_host                  = "联机·主机"
            mode_guest                 = "联机·客机"
            label_ip                   = "IP 地址："
            btn_apply_default          = "应用配置"
            btn_apply_single            = "应用单机配置"
            btn_apply_host              = "应用主机配置"
            btn_apply_guest             = "应用客机配置"
            btn_launch_default          = "一键启动"
            btn_launch_single           = "一键启动 (单机)"
            btn_launch_host             = "一键启动 (主机)"
            btn_launch_guest            = "一键启动 (客机)"
            btn_restore                 = "恢复上次快照"
            dlg_browse_desc             = "请选择塔科夫/SPT 所在的根目录（可以是游戏文件夹，也可以是上一层文件夹）"
            msgbox_blocked_title        = "操作被阻止"
            msgbox_blocked_body         = "检测到以下程序正在运行，无法继续：`n`n{0}`n`n请先完全关闭它们后再切换或启动。"
            msgbox_restore_title        = "确认恢复"
            msgbox_restore_body         = "将恢复到快照：{0}`n仅恢复 http.json 与 launcher 配置，不会移动 Fika 插件文件。`n是否继续？"
            msgbox_fatal_title          = "FikaToggler 错误"
            msgbox_fatal_prefix         = "脚本运行出错："
            log_tool_started            = "FikaToggler 启动。"
            log_first_use               = "首次使用，请点击「浏览」选择塔科夫/SPT 所在目录。"
            log_scanning                = "正在扫描：{0}"
            log_server_not_found        = "未找到 SPT 服务端（SPT.Server.exe）。"
            log_server_not_found_hint   = "请确认选择的目录包含 SPT 安装，或前往官方获取：{0}"
            log_client_not_found        = "找到服务端，但未找到客户端（BepInEx\plugins）。"
            log_client_not_found_hint   = "可能尚未安装 Fika 客户端插件，请参考：{0}"
            log_fika_plugin_missing     = "未检测到 Fika 客户端插件（{0}）。"
            log_fika_tool_scope         = "本工具仅负责切换，不负责安装。请先安装：{0}"
            log_fika_server_missing     = "未检测到 Fika 服务端模组（{0}）。"
            log_fika_server_install_hint = "请先完整安装 Fika 服务端部分：{0}"
            log_scan_complete           = "检测完成。"
            log_blocked                 = "操作已取消：检测到以下程序正在运行 -> {0}"
            log_blocked_hint            = "请先完全关闭游戏、SPT 服务端与 SPT 启动器后再试。"
            log_snapshot_created        = "已创建配置快照：{0}"
            log_snapshot_failed         = "创建快照失败（不影响后续操作）：{0}"
            log_no_server_root_restore  = "尚未定位服务端目录，无法恢复。"
            log_no_snapshot             = "没有可用的快照。"
            log_snapshot_restored       = "已恢复到快照：{0}"
            log_select_mode             = "请先选择一种模式。"
            log_no_valid_root           = "未检测到有效的服务端或客户端，请先浏览正确的目录。"
            log_apply_single            = "应用本地单人配置..."
            log_fika_disabled           = "已禁用 Fika 文件。"
            log_fika_already_disabled   = "Fika 已经禁用。"
            log_apply_single_done       = "本地单人配置应用完成。"
            log_need_ip_host            = "请填写本机虚拟 IP 再应用主机配置。"
            log_apply_host              = "应用联机主机配置（IP: {0}）..."
            log_fika_enabled            = "已启用 Fika 文件。"
            log_fika_already_enabled    = "Fika 已处于启用状态。"
            log_apply_host_done         = "主机配置应用完成。"
            log_need_ip_guest           = "请填写主机的虚拟 IP 再应用客机配置。"
            log_apply_guest             = "应用联机客机配置（主机 IP: {0}）..."
            log_fika_auto_enabled       = "检测到 Fika 被禁用，已自动启用。"
            log_fika_no_action          = "Fika 已启用，无需操作。"
            log_apply_guest_done        = "客机配置应用完成。"
            log_apply_error             = "切换过程中发生错误：{0}"
            log_apply_error_hint        = "可点击「恢复上次快照」尝试回退配置文件（不含 Fika 文件移动状态）。"
            log_http_updated            = "已更新 http.json -> backendIp = {0}"
            log_launcher_updated        = "已更新 launcher/config.json -> Server.Url = {0}"
            log_no_server_root_launch   = "未检测到服务端目录，无法启动。"
            log_server_exe_missing      = "找不到 SPT.Server.exe，请检查服务端目录。"
            log_launcher_exe_missing    = "找不到 SPT.Launcher.exe，请检查服务端目录。"
            log_starting_server         = "正在启动 SPT.Server.exe ..."
            log_waiting_server          = "等待服务端就绪（端口 6969）..."
            log_server_ready            = "服务端已就绪。"
            log_waited_seconds          = "已等待 {0} 秒..."
            log_wait_timeout            = "等待超时（{0} 秒）。"
            log_starting_launcher       = "正在启动 SPT.Launcher.exe ..."
            log_launch_done             = "启动完成。"
            log_server_timeout_hint     = "服务端启动超时，请检查日志，或手动启动 Launcher。"
            log_guest_launching         = "客机模式：直接启动 SPT.Launcher.exe ..."
            log_no_mode_selected        = "未选择有效模式，请先选择模式并应用配置。"
        }
        en = @{
            form_title              = "SPT / Fika Online-Offline Switcher"
            label_no_folder         = "No folder selected"
            btn_browse               = "Browse..."
            btn_lang_to_en           = "English"
            btn_lang_to_zh           = "中文"
            label_server_root_unknown = "Server Root: Not found"
            label_client_root_unknown = "Client Root: Not found"
            label_server_root        = "Server Root: {0}"
            label_client_root        = "Client Root: {0}"
            status_unknown            = "Status: Not scanned"
            status_cannot_detect      = "Status: Unable to detect"
            status_fika_missing       = "Status: Fika not installed"
            status_fika_server_missing = "Status: Fika server not installed"
            status_enabled            = "Status: Fika is currently ENABLED (multiplayer ready)"
            status_disabled           = "Status: Fika is currently DISABLED (single-player mode)"
            version_group_title       = "Version Info"
            version_detected_title    = "Detected (this machine):"
            version_tested_title      = "Verified working environment (tested by developer):"
            version_note              = "Note: version numbering may differ across release channels (the Fika server dll's embedded version does not always match the official Release tag). The version info above is for reference only -- actual runtime behavior takes precedence."
            mode_group_title          = "Select Mode"
            mode_single                = "Single Player"
            mode_host                  = "Multiplayer - Host"
            mode_guest                 = "Multiplayer - Guest"
            label_ip                   = "IP Address:"
            btn_apply_default          = "Apply Configuration"
            btn_apply_single            = "Apply Single-Player Config"
            btn_apply_host              = "Apply Host Config"
            btn_apply_guest             = "Apply Guest Config"
            btn_launch_default          = "Launch"
            btn_launch_single           = "Launch (Single Player)"
            btn_launch_host             = "Launch (Host)"
            btn_launch_guest            = "Launch (Guest)"
            btn_restore                 = "Restore Last Snapshot"
            dlg_browse_desc             = "Select the root folder of your Tarkov/SPT installation (can be the game folder itself or its parent folder)"
            msgbox_blocked_title        = "Operation Blocked"
            msgbox_blocked_body         = "The following processes are currently running, operation cannot continue:`n`n{0}`n`nPlease fully close them before switching or launching."
            msgbox_restore_title        = "Confirm Restore"
            msgbox_restore_body         = "This will restore snapshot: {0}`nOnly http.json and launcher config will be restored; Fika plugin files will NOT be moved.`nContinue?"
            msgbox_fatal_title          = "FikaToggler Error"
            msgbox_fatal_prefix         = "Script error occurred:"
            log_tool_started            = "FikaToggler started."
            log_first_use               = "First time use: click `"Browse`" to select your Tarkov/SPT folder."
            log_scanning                = "Scanning: {0}"
            log_server_not_found        = "SPT server (SPT.Server.exe) not found."
            log_server_not_found_hint   = "Please confirm the selected folder contains a valid SPT install, or get SPT from: {0}"
            log_client_not_found        = "Server found, but client (BepInEx\plugins) was not found."
            log_client_not_found_hint   = "The Fika client plugin may not be installed yet. See: {0}"
            log_fika_plugin_missing     = "Fika client plugin not detected ({0})."
            log_fika_tool_scope         = "This tool only toggles an existing install; it does not install Fika. Please install it first: {0}"
            log_fika_server_missing     = "Fika server mod not detected ({0})."
            log_fika_server_install_hint = "Please fully install the Fika server component first: {0}"
            log_scan_complete           = "Scan complete."
            log_blocked                 = "Operation cancelled: the following processes are running -> {0}"
            log_blocked_hint            = "Please fully close the game, SPT server, and SPT launcher, then try again."
            log_snapshot_created        = "Configuration snapshot created: {0}"
            log_snapshot_failed         = "Failed to create snapshot (does not affect further operation): {0}"
            log_no_server_root_restore  = "Server root not located yet; cannot restore."
            log_no_snapshot             = "No snapshot available."
            log_snapshot_restored       = "Restored snapshot: {0}"
            log_select_mode             = "Please select a mode first."
            log_no_valid_root           = "No valid server/client detected. Please browse to the correct folder first."
            log_apply_single            = "Applying local single-player configuration..."
            log_fika_disabled           = "Fika files disabled."
            log_fika_already_disabled   = "Fika is already disabled."
            log_apply_single_done       = "Local single-player configuration applied."
            log_need_ip_host            = "Please enter this machine's virtual IP before applying host configuration."
            log_apply_host              = "Applying multiplayer HOST configuration (IP: {0})..."
            log_fika_enabled            = "Fika files enabled."
            log_fika_already_enabled    = "Fika is already enabled."
            log_apply_host_done         = "Host configuration applied."
            log_need_ip_guest           = "Please enter the host's virtual IP before applying guest configuration."
            log_apply_guest             = "Applying multiplayer GUEST configuration (Host IP: {0})..."
            log_fika_auto_enabled       = "Fika was disabled; automatically re-enabled."
            log_fika_no_action          = "Fika already enabled, no action needed."
            log_apply_guest_done        = "Guest configuration applied."
            log_apply_error             = "An error occurred while switching: {0}"
            log_apply_error_hint        = "You can click `"Restore Last Snapshot`" to roll back config files (this does not include Fika file move state)."
            log_http_updated            = "Updated http.json -> backendIp = {0}"
            log_launcher_updated        = "Updated launcher/config.json -> Server.Url = {0}"
            log_no_server_root_launch   = "Server root not detected; cannot launch."
            log_server_exe_missing      = "SPT.Server.exe not found. Please check the server folder."
            log_launcher_exe_missing    = "SPT.Launcher.exe not found. Please check the server folder."
            log_starting_server         = "Starting SPT.Server.exe ..."
            log_waiting_server          = "Waiting for server to become ready (port 6969)..."
            log_server_ready            = "Server is ready."
            log_waited_seconds          = "Waited {0} seconds..."
            log_wait_timeout            = "Timed out after {0} seconds."
            log_starting_launcher       = "Starting SPT.Launcher.exe ..."
            log_launch_done             = "Launch complete."
            log_server_timeout_hint     = "Server startup timed out. Check the log, or start the Launcher manually."
            log_guest_launching         = "Guest mode: launching SPT.Launcher.exe directly..."
            log_no_mode_selected        = "No valid mode selected. Please select a mode and apply configuration first."
        }
    }

    function Get-DefaultLanguage {
        # 当前仅支持中/英两种语言。
        # 规则：简体中文系统环境（zh-CN / zh-Hans）默认中文界面；其余一律默认英文界面。
        $culture = [System.Globalization.CultureInfo]::CurrentUICulture.Name
        if ($culture -like "zh-CN*" -or $culture -like "zh-Hans*") {
            return "zh"
        }
        return "en"
    }

    $script:CurrentLang = Get-DefaultLanguage

    function Tr {
        param([string]$Key, [object[]]$FormatArgs)
        $template = $Strings[$script:CurrentLang][$Key]
        if (-not $template) { return "[$Key]" }
        if ($FormatArgs) { return ($template -f $FormatArgs) }
        return $template
    }

    # ---------- 日志 ----------
    function Initialize-LogFile {
        if (-not (Test-Path $LogDir)) {
            New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
        }
        $stamp = Get-Date -Format "yyyyMMdd"
        $script:LogFilePath = Join-Path $LogDir "$stamp.log"
    }

    function Log($msg) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $line = "[$timestamp] $msg"
        if ($txtLog) { $txtLog.AppendText("$line`r`n") }
        if ($script:LogFilePath) {
            try { Add-Content -Path $script:LogFilePath -Value $line -Encoding UTF8 } catch {}
        }
    }

    # ---------- 进程占用检测 ----------
    function Get-RunningCriticalProcesses {
        $names = @("SPT.Server", "SPT.Launcher", "EscapeFromTarkov")
        $running = @()
        foreach ($n in $names) {
            if (Get-Process -Name $n -ErrorAction SilentlyContinue) { $running += $n }
        }
        return $running
    }

    function Test-SafeToModify {
        $blockers = Get-RunningCriticalProcesses
        if ($blockers.Count -gt 0) {
            Log (Tr 'log_blocked' @(($blockers -join ', ')))
            Log (Tr 'log_blocked_hint')
            [System.Windows.Forms.MessageBox]::Show(
                (Tr 'msgbox_blocked_body' @(($blockers -join "`n"))),
                (Tr 'msgbox_blocked_title'),
                "OK", "Warning"
            ) | Out-Null
            return $false
        }
        return $true
    }

    # ---------- 目录定位 ----------
    function Test-ServerRootPath($p) {
        (Test-Path (Join-Path $p "SPT.Server.exe")) -and (Test-Path (Join-Path $p "user\mods"))
    }
    function Test-ClientRootPath($p) {
        Test-Path (Join-Path $p "BepInEx\plugins")
    }
    function Find-ServerRoot($base) {
        if (Test-ServerRootPath $base) { return $base }
        $dirs = Get-ChildItem -Path $base -Recurse -Depth 3 -Directory -ErrorAction SilentlyContinue
        foreach ($d in $dirs) { if (Test-ServerRootPath $d.FullName) { return $d.FullName } }
        return $null
    }
    function Find-ClientRoot($base, $serverRoot) {
        if ($serverRoot) {
            $launcherCfg = Join-Path $serverRoot "user\launcher\config.json"
            if (Test-Path $launcherCfg) {
                try {
                    $cfg = Get-Content $launcherCfg -Raw | ConvertFrom-Json
                    if ($cfg.GamePath -and (Test-ClientRootPath $cfg.GamePath)) { return $cfg.GamePath }
                } catch {}
            }
        }
        if (Test-ClientRootPath $base) { return $base }
        $dirs = Get-ChildItem -Path $base -Recurse -Depth 3 -Directory -ErrorAction SilentlyContinue
        foreach ($d in $dirs) { if (Test-ClientRootPath $d.FullName) { return $d.FullName } }
        return $null
    }

    function Load-Config {
        if (Test-Path $ConfigFile) {
            try { return Get-Content $ConfigFile -Raw | ConvertFrom-Json } catch { return $null }
        }
        return $null
    }
    function Save-Config($base) {
        @{ BaseFolder = $base } | ConvertTo-Json | Set-Content $ConfigFile
    }

    # ---------- 端口就绪检测 ----------
    function Wait-ServerReady {
        param([int]$TimeoutSeconds = 90)
        $elapsed = 0
        Log (Tr 'log_waiting_server')
        while ($elapsed -lt $TimeoutSeconds) {
            $portOpen = Test-NetConnection -ComputerName "127.0.0.1" -Port 6969 -WarningAction SilentlyContinue -InformationLevel Quiet
            if ($portOpen) { Log (Tr 'log_server_ready'); return $true }
            Start-Sleep -Seconds 1
            $elapsed++
            if ($elapsed % 5 -eq 0) { Log (Tr 'log_waited_seconds' @($elapsed)) }
        }
        Log (Tr 'log_wait_timeout' @($TimeoutSeconds))
        return $false
    }

    # ---------- 版本检测 ----------
    function Get-AssemblyVersion($path) {
        if (Test-Path $path) {
            try {
                $v = (Get-Item $path).VersionInfo.FileVersion
                if ([string]::IsNullOrWhiteSpace($v)) { return "?" }
                return $v.Trim()
            } catch { return "?" }
        }
        return "-"
    }

    function Show-VersionInfo {
        if (-not $script:ServerRoot -or -not $script:ClientRoot) { return }

        $eftExe       = Join-Path $script:ClientRoot "EscapeFromTarkov.exe"
        $sptServerExe = Join-Path $script:ServerRoot "SPT.Server.exe"
        $fikaPlugin   = Join-Path $script:ClientRoot "BepInEx\plugins\$FikaPluginFolder\Fika.Core.dll"
        $fikaServer   = Join-Path $script:ServerRoot "user\mods\$FikaServerFolder\FikaServer.dll"
        $disabledDir  = Join-Path $script:ServerRoot "_FikaDisabled"

        if (-not (Test-Path $fikaPlugin)) { $fikaPlugin = Join-Path $disabledDir "plugins\$FikaPluginFolder\Fika.Core.dll" }
        if (-not (Test-Path $fikaServer)) { $fikaServer = Join-Path $disabledDir "mods\$FikaServerFolder\FikaServer.dll" }

        $eftVer        = Get-AssemblyVersion $eftExe
        $sptVer        = Get-AssemblyVersion $sptServerExe
        $fikaPluginVer = Get-AssemblyVersion $fikaPlugin
        $fikaServerVer = Get-AssemblyVersion $fikaServer

        $lblDetectedTitle.Text = Tr 'version_detected_title'
        $lblDetectedValue.Text = "SPT: $sptVer  /  Fika Plugin: $fikaPluginVer  /  Fika Server: $fikaServerVer`r`nEFT: $eftVer"
        $lblTestedTitle.Text = Tr 'version_tested_title'
        $lblTestedValue.Text = ("SPT {0}  /  Fika Plugin {1}  /  Fika Server {2}" -f $TestedVersions.SPT, $TestedVersions.FikaPlugin, $TestedVersions.FikaServer)
        $lblVersionNote.Text = Tr 'version_note'
    }

    # ---------- 配置快照与恢复 ----------
    function New-ConfigSnapshot {
        if (-not $script:ServerRoot) { return }
        try {
            if (-not (Test-Path $SnapshotDir)) { New-Item -ItemType Directory -Force -Path $SnapshotDir | Out-Null }
            $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $dest = Join-Path $SnapshotDir $stamp
            New-Item -ItemType Directory -Force -Path $dest | Out-Null

            $httpJson = Join-Path $script:ServerRoot "SPT_Data\Configs\http.json"
            $launcherCfg = Join-Path $script:ServerRoot "user\launcher\config.json"
            if (Test-Path $httpJson) { Copy-Item $httpJson (Join-Path $dest "http.json") -Force }
            if (Test-Path $launcherCfg) { Copy-Item $launcherCfg (Join-Path $dest "launcher.config.json") -Force }

            $pluginActive = Join-Path $script:ClientRoot "BepInEx\plugins\$FikaPluginFolder"
            $fikaState = if (Test-Path $pluginActive) { "enabled" } else { "disabled" }
            @{ FikaState = $fikaState; Timestamp = $stamp } | ConvertTo-Json | Set-Content (Join-Path $dest "meta.json")

            $all = Get-ChildItem $SnapshotDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
            if ($all.Count -gt $MaxSnapshots) {
                $all | Select-Object -Skip $MaxSnapshots | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            }
            Log (Tr 'log_snapshot_created' @($stamp))
        } catch {
            Log (Tr 'log_snapshot_failed' @($_.Exception.Message))
        }
    }

    function Restore-LastSnapshot {
        if (-not $script:ServerRoot) { Log (Tr 'log_no_server_root_restore'); return }
        if (-not (Test-SafeToModify)) { return }
        if (-not (Test-Path $SnapshotDir)) { Log (Tr 'log_no_snapshot'); return }

        $latest = Get-ChildItem $SnapshotDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
        if (-not $latest) { Log (Tr 'log_no_snapshot'); return }

        $confirm = [System.Windows.Forms.MessageBox]::Show(
            (Tr 'msgbox_restore_body' @($latest.Name)),
            (Tr 'msgbox_restore_title'),
            "YesNo", "Question"
        )
        if ($confirm -ne "Yes") { return }

        $httpSrc = Join-Path $latest.FullName "http.json"
        $launcherSrc = Join-Path $latest.FullName "launcher.config.json"
        $httpDst = Join-Path $script:ServerRoot "SPT_Data\Configs\http.json"
        $launcherDst = Join-Path $script:ServerRoot "user\launcher\config.json"

        if (Test-Path $httpSrc) { Copy-Item $httpSrc $httpDst -Force }
        if (Test-Path $launcherSrc) { Copy-Item $launcherSrc $launcherDst -Force }

        Log (Tr 'log_snapshot_restored' @($latest.Name))
        Do-Scan $script:BaseFolder
    }

    # ---------- 扫描逻辑 ----------
    function Do-Scan($base) {
        $txtLog.Clear()
        Log (Tr 'log_scanning' @($base))
        $script:ServerRoot = Find-ServerRoot $base
        if (-not $script:ServerRoot) {
            Log (Tr 'log_server_not_found')
            Log (Tr 'log_server_not_found_hint' @($SptOfficial))
            $lblServerRoot.Text = Tr 'label_server_root_unknown'
            $lblClientRoot.Text = Tr 'label_client_root_unknown'
            $lblStatus.Text = Tr 'status_cannot_detect'
            Clear-VersionLabels
            $btnApply.Enabled = $false; $btnLaunch.Enabled = $false; $btnRestore.Enabled = $false
            return
        }
        $script:ClientRoot = Find-ClientRoot $base $script:ServerRoot
        $lblServerRoot.Text = Tr 'label_server_root' @($script:ServerRoot)

        if (-not $script:ClientRoot) {
            Log (Tr 'log_client_not_found')
            Log (Tr 'log_client_not_found_hint' @($FikaWiki))
            $lblClientRoot.Text = Tr 'label_client_root_unknown'
            $lblStatus.Text = Tr 'status_cannot_detect'
            Clear-VersionLabels
            $btnApply.Enabled = $false; $btnLaunch.Enabled = $false
            $btnRestore.Enabled = (Test-Path $SnapshotDir)
            return
        }
        $lblClientRoot.Text = Tr 'label_client_root' @($script:ClientRoot)

        $pluginActive = Join-Path $script:ClientRoot "BepInEx\plugins\$FikaPluginFolder"
        $disabledDir  = Join-Path $script:ServerRoot "_FikaDisabled"
        $pluginBackup = Join-Path $disabledDir "plugins\$FikaPluginFolder"
        $serverActive = Join-Path $script:ServerRoot "user\mods\$FikaServerFolder"
        $serverBackup = Join-Path $disabledDir "mods\$FikaServerFolder"

        if (-not (Test-Path $pluginActive) -and -not (Test-Path $pluginBackup)) {
            Log (Tr 'log_fika_plugin_missing' @($FikaPluginFolder))
            Log (Tr 'log_fika_tool_scope' @($FikaWiki))
            $lblStatus.Text = Tr 'status_fika_missing'
            Clear-VersionLabels
            $btnApply.Enabled = $false; $btnLaunch.Enabled = $false
            $btnRestore.Enabled = (Test-Path $SnapshotDir)
            return
        }
        if (-not (Test-Path $serverActive) -and -not (Test-Path $serverBackup)) {
            Log (Tr 'log_fika_server_missing' @($FikaServerFolder))
            Log (Tr 'log_fika_server_install_hint' @($FikaWiki))
            $lblStatus.Text = Tr 'status_fika_server_missing'
            Clear-VersionLabels
            $btnApply.Enabled = $false; $btnLaunch.Enabled = $false
            $btnRestore.Enabled = (Test-Path $SnapshotDir)
            return
        }

        $btnApply.Enabled = $true
        $btnLaunch.Enabled = $true
        $btnRestore.Enabled = (Test-Path $SnapshotDir)

        $lblStatus.Text = if (Test-Path $pluginActive) { Tr 'status_enabled' } else { Tr 'status_disabled' }
        Log (Tr 'log_scan_complete')
        Show-VersionInfo
    }

    function Clear-VersionLabels {
        $lblDetectedTitle.Text = ""
        $lblDetectedValue.Text = ""
        $lblTestedTitle.Text = ""
        $lblTestedValue.Text = ""
        $lblVersionNote.Text = ""
    }

    # ---------- 应用配置 ----------
    function Apply-Configuration {
        if (-not (Test-SafeToModify)) { return }

        $mode = $null
        if ($radioSingle.Checked) { $mode = "single" }
        elseif ($radioHost.Checked) { $mode = "host" }
        elseif ($radioGuest.Checked) { $mode = "guest" }
        else { Log (Tr 'log_select_mode'); return }

        if (-not $script:ServerRoot -or -not $script:ClientRoot) {
            Log (Tr 'log_no_valid_root'); return
        }

        New-ConfigSnapshot

        $pluginsDir   = Join-Path $script:ClientRoot "BepInEx\plugins"
        $modsDir      = Join-Path $script:ServerRoot "user\mods"
        $disabledDir  = Join-Path $script:ServerRoot "_FikaDisabled"
        $pluginActive = Join-Path $pluginsDir $FikaPluginFolder
        $pluginBackup = Join-Path $disabledDir "plugins\$FikaPluginFolder"
        $serverActive = Join-Path $modsDir $FikaServerFolder
        $serverBackup = Join-Path $disabledDir "mods\$FikaServerFolder"

        New-Item -ItemType Directory -Force -Path (Join-Path $disabledDir "plugins") | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $disabledDir "mods") | Out-Null

        $ip = $txtIp.Text.Trim()

        try {
            switch ($mode) {
                "single" {
                    Log (Tr 'log_apply_single')
                    if (Test-Path $pluginActive) {
                        Move-Item $pluginActive $pluginBackup -Force
                        Move-Item $serverActive $serverBackup -Force
                        Log (Tr 'log_fika_disabled')
                    } else { Log (Tr 'log_fika_already_disabled') }
                    Set-Addresses -HttpIp "127.0.0.1" -LauncherUrl "https://127.0.0.1:6969"
                    Log (Tr 'log_apply_single_done')
                }
                "host" {
                    if ([string]::IsNullOrWhiteSpace($ip)) { Log (Tr 'log_need_ip_host'); return }
                    Log (Tr 'log_apply_host' @($ip))
                    if (Test-Path $pluginBackup) {
                        Move-Item $pluginBackup $pluginActive -Force
                        Move-Item $serverBackup $serverActive -Force
                        Log (Tr 'log_fika_enabled')
                    } else { Log (Tr 'log_fika_already_enabled') }
                    Set-Addresses -HttpIp $ip -LauncherUrl "https://${ip}:6969"
                    Log (Tr 'log_apply_host_done')
                }
                "guest" {
                    if ([string]::IsNullOrWhiteSpace($ip)) { Log (Tr 'log_need_ip_guest'); return }
                    Log (Tr 'log_apply_guest' @($ip))
                    if (Test-Path $pluginBackup) {
                        Move-Item $pluginBackup $pluginActive -Force
                        Move-Item $serverBackup $serverActive -Force
                        Log (Tr 'log_fika_auto_enabled')
                    } else { Log (Tr 'log_fika_no_action') }
                    Set-Addresses -HttpIp $null -LauncherUrl "https://${ip}:6969" -SkipHttp
                    Log (Tr 'log_apply_guest_done')
                }
            }
        } catch {
            Log (Tr 'log_apply_error' @($_.Exception.Message))
            Log (Tr 'log_apply_error_hint')
        }

        Do-Scan $script:BaseFolder
    }

    function Set-Addresses {
        param([string]$HttpIp, [string]$LauncherUrl, [switch]$SkipHttp)
        if (-not $SkipHttp -and $HttpIp) {
            $httpJson = Join-Path $script:ServerRoot "SPT_Data\Configs\http.json"
            if (Test-Path $httpJson) {
                $h = Get-Content $httpJson -Raw | ConvertFrom-Json
                $h.backendIp = $HttpIp
                $h | ConvertTo-Json -Depth 10 | Set-Content $httpJson
                Log (Tr 'log_http_updated' @($HttpIp))
            }
        }
        $launcherCfg = Join-Path $script:ServerRoot "user\launcher\config.json"
        if (Test-Path $launcherCfg) {
            $l = Get-Content $launcherCfg -Raw | ConvertFrom-Json
            $l.Server.Url = $LauncherUrl
            $l | ConvertTo-Json -Depth 10 | Set-Content $launcherCfg
            Log (Tr 'log_launcher_updated' @($LauncherUrl))
        }
    }

    # ---------- 一键启动 ----------
    function Start-Game {
        if (-not (Test-SafeToModify)) { return }
        if (-not $script:ServerRoot) { Log (Tr 'log_no_server_root_launch'); return }

        $serverExe = Join-Path $script:ServerRoot "SPT.Server.exe"
        $launcherExe = Join-Path $script:ServerRoot "SPT.Launcher.exe"
        if (-not (Test-Path $serverExe)) { Log (Tr 'log_server_exe_missing'); return }
        if (-not (Test-Path $launcherExe)) { Log (Tr 'log_launcher_exe_missing'); return }

        $mode = $null
        if ($radioSingle.Checked) { $mode = "single" }
        elseif ($radioHost.Checked) { $mode = "host" }
        elseif ($radioGuest.Checked) { $mode = "guest" }

        if ($mode -in "single", "host") {
            Log (Tr 'log_starting_server')
            Start-Process -FilePath $serverExe -WorkingDirectory $script:ServerRoot
            if (Wait-ServerReady -TimeoutSeconds 90) {
                Log (Tr 'log_starting_launcher')
                Start-Process -FilePath $launcherExe -WorkingDirectory $script:ServerRoot
                Log (Tr 'log_launch_done')
            } else {
                Log (Tr 'log_server_timeout_hint')
            }
        } elseif ($mode -eq "guest") {
            Log (Tr 'log_guest_launching')
            Start-Process -FilePath $launcherExe -WorkingDirectory $script:ServerRoot
            Log (Tr 'log_launch_done')
        } else {
            Log (Tr 'log_no_mode_selected')
        }
    }

    # ---------- 根据当前语言+模式刷新按钮文字 ----------
    function Update-ModeButtonTexts {
        if ($radioSingle.Checked) {
            $btnApply.Text = Tr 'btn_apply_single'
            $btnLaunch.Text = Tr 'btn_launch_single'
        } elseif ($radioHost.Checked) {
            $btnApply.Text = Tr 'btn_apply_host'
            $btnLaunch.Text = Tr 'btn_launch_host'
        } elseif ($radioGuest.Checked) {
            $btnApply.Text = Tr 'btn_apply_guest'
            $btnLaunch.Text = Tr 'btn_launch_guest'
        } else {
            $btnApply.Text = Tr 'btn_apply_default'
            $btnLaunch.Text = Tr 'btn_launch_default'
        }
    }

    function Apply-StaticUI {
        $form.Text = Tr 'form_title'
        if (-not $script:BaseFolder) { $lblFolder.Text = Tr 'label_no_folder' }
        $btnBrowse.Text = Tr 'btn_browse'
        $btnLang.Text = if ($script:CurrentLang -eq 'zh') { Tr 'btn_lang_to_en' } else { Tr 'btn_lang_to_zh' }
        $groupMode.Text = Tr 'mode_group_title'
        $radioSingle.Text = Tr 'mode_single'
        $radioHost.Text = Tr 'mode_host'
        $radioGuest.Text = Tr 'mode_guest'
        $lblIp.Text = Tr 'label_ip'
        $btnRestore.Text = Tr 'btn_restore'
        $versionGroup.Text = Tr 'version_group_title'
        Update-ModeButtonTexts
    }

    # ===================== 构建窗体 =====================
    $form = New-Object System.Windows.Forms.Form
    $form.Size = New-Object System.Drawing.Size(660, 735)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $lblFolder = New-Object System.Windows.Forms.Label
    $lblFolder.Location = New-Object System.Drawing.Point(15, 15)
    $lblFolder.Size = New-Object System.Drawing.Size(430, 20)
    $form.Controls.Add($lblFolder)

    $btnBrowse = New-Object System.Windows.Forms.Button
    $btnBrowse.Location = New-Object System.Drawing.Point(455, 12)
    $btnBrowse.Size = New-Object System.Drawing.Size(80, 25)
    $form.Controls.Add($btnBrowse)

    $btnLang = New-Object System.Windows.Forms.Button
    $btnLang.Location = New-Object System.Drawing.Point(545, 12)
    $btnLang.Size = New-Object System.Drawing.Size(90, 25)
    $form.Controls.Add($btnLang)

    $lblServerRoot = New-Object System.Windows.Forms.Label
    $lblServerRoot.Location = New-Object System.Drawing.Point(15, 45)
    $lblServerRoot.Size = New-Object System.Drawing.Size(620, 20)
    $form.Controls.Add($lblServerRoot)

    $lblClientRoot = New-Object System.Windows.Forms.Label
    $lblClientRoot.Location = New-Object System.Drawing.Point(15, 70)
    $lblClientRoot.Size = New-Object System.Drawing.Size(620, 20)
    $form.Controls.Add($lblClientRoot)

    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Location = New-Object System.Drawing.Point(15, 95)
    $lblStatus.Size = New-Object System.Drawing.Size(620, 20)
    $lblStatus.Font = New-Object System.Drawing.Font($lblStatus.Font, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($lblStatus)

    $versionGroup = New-Object System.Windows.Forms.GroupBox
    $versionGroup.Location = New-Object System.Drawing.Point(15, 120)
    $versionGroup.Size = New-Object System.Drawing.Size(620, 175)
    $form.Controls.Add($versionGroup)

    $lblDetectedTitle = New-Object System.Windows.Forms.Label
    $lblDetectedTitle.Location = New-Object System.Drawing.Point(15, 20)
    $lblDetectedTitle.Size = New-Object System.Drawing.Size(580, 18)
    $lblDetectedTitle.Font = New-Object System.Drawing.Font($lblDetectedTitle.Font, [System.Drawing.FontStyle]::Bold)
    $versionGroup.Controls.Add($lblDetectedTitle)

    $lblDetectedValue = New-Object System.Windows.Forms.Label
    $lblDetectedValue.Location = New-Object System.Drawing.Point(15, 40)
    $lblDetectedValue.Size = New-Object System.Drawing.Size(590, 36)
    $lblDetectedValue.ForeColor = [System.Drawing.Color]::FromArgb(0, 90, 158)
    $versionGroup.Controls.Add($lblDetectedValue)

    $lblTestedTitle = New-Object System.Windows.Forms.Label
    $lblTestedTitle.Location = New-Object System.Drawing.Point(15, 78)
    $lblTestedTitle.Size = New-Object System.Drawing.Size(580, 18)
    $lblTestedTitle.Font = New-Object System.Drawing.Font($lblTestedTitle.Font, [System.Drawing.FontStyle]::Bold)
    $versionGroup.Controls.Add($lblTestedTitle)

    $lblTestedValue = New-Object System.Windows.Forms.Label
    $lblTestedValue.Location = New-Object System.Drawing.Point(15, 96)
    $lblTestedValue.Size = New-Object System.Drawing.Size(590, 18)
    $lblTestedValue.ForeColor = [System.Drawing.Color]::DarkGreen
    $versionGroup.Controls.Add($lblTestedValue)

    $lblVersionNote = New-Object System.Windows.Forms.Label
    $lblVersionNote.Location = New-Object System.Drawing.Point(15, 116)
    $lblVersionNote.Size = New-Object System.Drawing.Size(590, 40)
    $lblVersionNote.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 7.5)
    $lblVersionNote.ForeColor = [System.Drawing.Color]::Gray
    $versionGroup.Controls.Add($lblVersionNote)

    $groupMode = New-Object System.Windows.Forms.GroupBox
    $groupMode.Location = New-Object System.Drawing.Point(15, 305)
    $groupMode.Size = New-Object System.Drawing.Size(620, 50)
    $form.Controls.Add($groupMode)

    $radioSingle = New-Object System.Windows.Forms.RadioButton
    $radioSingle.Location = New-Object System.Drawing.Point(20, 20)
    $radioSingle.Size = New-Object System.Drawing.Size(110, 20)
    $groupMode.Controls.Add($radioSingle)

    $radioHost = New-Object System.Windows.Forms.RadioButton
    $radioHost.Location = New-Object System.Drawing.Point(150, 20)
    $radioHost.Size = New-Object System.Drawing.Size(130, 20)
    $groupMode.Controls.Add($radioHost)

    $radioGuest = New-Object System.Windows.Forms.RadioButton
    $radioGuest.Location = New-Object System.Drawing.Point(290, 20)
    $radioGuest.Size = New-Object System.Drawing.Size(130, 20)
    $groupMode.Controls.Add($radioGuest)

    $lblIp = New-Object System.Windows.Forms.Label
    $lblIp.Location = New-Object System.Drawing.Point(15, 370)
    $lblIp.Size = New-Object System.Drawing.Size(70, 20)
    $form.Controls.Add($lblIp)

    $txtIp = New-Object System.Windows.Forms.TextBox
    $txtIp.Location = New-Object System.Drawing.Point(90, 367)
    $txtIp.Size = New-Object System.Drawing.Size(150, 20)
    $form.Controls.Add($txtIp)

    $btnApply = New-Object System.Windows.Forms.Button
    $btnApply.Location = New-Object System.Drawing.Point(255, 365)
    $btnApply.Size = New-Object System.Drawing.Size(120, 28)
    $btnApply.Enabled = $false
    $form.Controls.Add($btnApply)

    $btnLaunch = New-Object System.Windows.Forms.Button
    $btnLaunch.Location = New-Object System.Drawing.Point(385, 365)
    $btnLaunch.Size = New-Object System.Drawing.Size(110, 28)
    $btnLaunch.Enabled = $false
    $form.Controls.Add($btnLaunch)

    $btnRestore = New-Object System.Windows.Forms.Button
    $btnRestore.Location = New-Object System.Drawing.Point(505, 365)
    $btnRestore.Size = New-Object System.Drawing.Size(130, 28)
    $btnRestore.Enabled = $false
    $form.Controls.Add($btnRestore)

    $txtLog = New-Object System.Windows.Forms.TextBox
    $txtLog.Multiline = $true
    $txtLog.ScrollBars = "Vertical"
    $txtLog.ReadOnly = $true
    $txtLog.Font = New-Object System.Drawing.Font("Consolas", 9)
    $txtLog.Location = New-Object System.Drawing.Point(15, 405)
    $txtLog.Size = New-Object System.Drawing.Size(620, 280)
    $form.Controls.Add($txtLog)

    # ---------- 事件绑定 ----------
    $btnBrowse.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.Description = Tr 'dlg_browse_desc'
        if ($dlg.ShowDialog() -eq "OK") {
            $script:BaseFolder = $dlg.SelectedPath
            $lblFolder.Text = $script:BaseFolder
            Save-Config $script:BaseFolder
            Do-Scan $script:BaseFolder
        }
    })

    $btnApply.Add_Click({ Apply-Configuration })
    $btnLaunch.Add_Click({ Start-Game })
    $btnRestore.Add_Click({ Restore-LastSnapshot })

    $btnLang.Add_Click({
        $script:CurrentLang = if ($script:CurrentLang -eq 'zh') { 'en' } else { 'zh' }
        Apply-StaticUI
        if ($script:BaseFolder) { Do-Scan $script:BaseFolder } else { Log (Tr 'log_first_use') }
    })

    $radioSingle.Add_CheckedChanged({ if ($radioSingle.Checked) { $txtIp.Text = ""; $txtIp.Enabled = $false; Update-ModeButtonTexts } })
    $radioHost.Add_CheckedChanged({ if ($radioHost.Checked) { $txtIp.Enabled = $true; $txtIp.Text = ""; Update-ModeButtonTexts } })
    $radioGuest.Add_CheckedChanged({ if ($radioGuest.Checked) { $txtIp.Enabled = $true; $txtIp.Text = ""; Update-ModeButtonTexts } })
    $radioHost.Checked = $true

    # ---------- 启动初始化 ----------
    Apply-StaticUI
    Initialize-LogFile
    Log (Tr 'log_tool_started')

    $cfg = Load-Config
    if ($cfg -and $cfg.BaseFolder -and (Test-Path $cfg.BaseFolder)) {
        $script:BaseFolder = $cfg.BaseFolder
        $lblFolder.Text = $script:BaseFolder
        Do-Scan $script:BaseFolder
    } else {
        Log (Tr 'log_first_use')
        $btnRestore.Enabled = (Test-Path $SnapshotDir)
    }

    [void]$form.ShowDialog()

} catch {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show("$($_.Exception.Message)`n`n$($_.InvocationInfo.PositionMessage)", "FikaToggler Error", "OK", "Error")
}
