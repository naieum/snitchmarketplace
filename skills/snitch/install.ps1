param(
    [switch]$Yes,
    [switch]$NoColor
)

$ErrorActionPreference = "Stop"

$UseColor = (-not $NoColor) -and $Host.UI.SupportsVirtualTerminal
if ($UseColor) {
    $ESC = [char]27
    $BOLD = "$ESC[1m"
    $WHITE = "$ESC[38;5;255m"
    $GRAY = "$ESC[38;5;242m"
    $DARK = "$ESC[38;5;237m"
    $GREEN = "$ESC[38;5;114m"
    $RED = "$ESC[38;5;204m"
    $YELLOW = "$ESC[38;5;222m"
    $CYAN = "$ESC[38;5;117m"
    $ACCENT = "$ESC[38;5;75m"
    $RESET = "$ESC[0m"
} else {
    $BOLD = ""
    $WHITE = ""
    $GRAY = ""
    $DARK = ""
    $GREEN = ""
    $RED = ""
    $YELLOW = ""
    $CYAN = ""
    $ACCENT = ""
    $RESET = ""
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SkillFile = Join-Path $ScriptDir "SKILL.md"
$CategoriesDir = Join-Path $ScriptDir "categories"
$ReferencesDir = Join-Path $ScriptDir "references"
$ComplianceDir = Join-Path $ScriptDir "compliance-templates"
$CustomRulesDir = Join-Path $ScriptDir "custom-rules"
$ConfigFile = Join-Path $ScriptDir "snitch.config.md"

if (-not (Test-Path $SkillFile)) {
    Write-Host ""
    Write-Host "${RED}error:${RESET} SKILL.md not found in $ScriptDir"
    Write-Host ""
    exit 1
}

if (-not (Test-Path $CategoriesDir)) {
    Write-Host ""
    Write-Host "${RED}error:${RESET} categories/ not found in $ScriptDir"
    Write-Host ""
    exit 1
}

$CatCount = (Get-ChildItem -Path $CategoriesDir -Filter "*.md" -ErrorAction SilentlyContinue).Count
$HasExtras = (Test-Path $ReferencesDir) -or (Test-Path $ComplianceDir) -or (Test-Path $CustomRulesDir) -or (Test-Path $ConfigFile)

function Write-Hr {
    Write-Host "  ${DARK}------------------------------------------------------------${RESET}"
}

function Write-Header {
    Write-Host ""
    Write-Hr
    Write-Host "  ${BOLD}${WHITE}Snitch Installer${RESET}"
    Write-Host "  ${GRAY}Install Snitch into supported AI coding tools${RESET}"
    $payload = "  ${DARK}Payload:${RESET} SKILL.md + ${WHITE}$CatCount${RESET} categories"
    if ($HasExtras) {
        $payload += " + extras"
    }
    Write-Host $payload
    Write-Host "  ${ACCENT}snitchplugin.com${RESET}"
    Write-Hr
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "  ${BOLD}$Title${RESET}"
}

function Write-Detected {
    param([string]$Name, [string]$Detail)
    Write-Host ("    {0}yes{1} {2,-17} {3}{4}{5}" -f $GREEN, $RESET, $Name, $GRAY, $Detail, $RESET)
}

function Write-Missing {
    param([string]$Name)
    Write-Host ("    {0}no {1} {2,-17}" -f $DARK, $RESET, $Name)
}

function Write-Result {
    param([string]$Color, [string]$Prefix, [string]$Name, [string]$Detail)
    Write-Host ("    {0}{1}{2} {3,-17} {4}{5}{6}" -f $Color, $Prefix, $RESET, $Name, $GRAY, $Detail, $RESET)
}

function Write-Action {
    param([string]$Name, [string]$Detail)
    Write-Host ("    {0}..{1} {2,-17} {3}{4}{5}" -f $CYAN, $RESET, $Name, $GRAY, $Detail, $RESET)
}

function Expand-UserPath {
    param([string]$Path)
    if (-not $Path) { return "" }
    if ($Path -eq "~") { return $HOME }
    if ($Path.StartsWith("~\")) { return Join-Path $HOME $Path.Substring(2) }
    if ($Path.StartsWith("~/")) { return Join-Path $HOME $Path.Substring(2) }
    return $Path
}

function Copy-Extras {
    param([string]$Dest)

    if (Test-Path $ReferencesDir) {
        $refDest = Join-Path $Dest "references"
        if (Test-Path $refDest) { Remove-Item $refDest -Recurse -Force }
        Copy-Item $ReferencesDir -Destination $refDest -Recurse -Force
    }

    if (Test-Path $ComplianceDir) {
        $complianceDest = Join-Path $Dest "compliance-templates"
        if (Test-Path $complianceDest) { Remove-Item $complianceDest -Recurse -Force }
        Copy-Item $ComplianceDir -Destination $complianceDest -Recurse -Force
    }

    if (Test-Path $CustomRulesDir) {
        $rulesDest = Join-Path $Dest "custom-rules"
        if (Test-Path $rulesDest) { Remove-Item $rulesDest -Recurse -Force }
        Copy-Item $CustomRulesDir -Destination $rulesDest -Recurse -Force
    }

    if (Test-Path $ConfigFile) {
        Copy-Item $ConfigFile -Destination (Join-Path $Dest "snitch.config.md") -Force
    }
}

function Copy-SkillDir {
    param([string]$Dest)
    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    Copy-Item $SkillFile -Destination (Join-Path $Dest "snitch-audit.md") -Force
    $catDest = Join-Path $Dest "categories"
    if (Test-Path $catDest) { Remove-Item $catDest -Recurse -Force }
    Copy-Item $CategoriesDir -Destination $catDest -Recurse -Force
    Copy-Extras -Dest $Dest
}

function Copy-ManualDir {
    param([string]$Dest)
    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    Copy-Item $SkillFile -Destination (Join-Path $Dest "SKILL.md") -Force
    $catDest = Join-Path $Dest "categories"
    if (Test-Path $catDest) { Remove-Item $catDest -Recurse -Force }
    Copy-Item $CategoriesDir -Destination $catDest -Recurse -Force
    Copy-Extras -Dest $Dest
}

function Append-SkillToFile {
    param([string]$Target)

    $targetDir = Split-Path -Parent $Target
    if ($targetDir) {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    }

    if (Test-Path $Target) {
        $content = Get-Content $Target -Raw -ErrorAction SilentlyContinue
        if ($content -and ($content.Contains("snitch.live") -or $content.Contains("snitchplugin.com"))) {
            return "already_installed"
        }
    } else {
        New-Item -ItemType File -Force -Path $Target | Out-Null
    }

    if ((Get-Item $Target).Length -gt 0) {
        Add-Content -Path $Target -Value "`n`n"
    }

    Get-Content $SkillFile -Raw | Add-Content -Path $Target
    $catDest = Join-Path $targetDir "categories"
    if (Test-Path $catDest) { Remove-Item $catDest -Recurse -Force }
    Copy-Item $CategoriesDir -Destination $catDest -Recurse -Force
    Copy-Extras -Dest $targetDir
    return "installed"
}

function Test-VscodeExt {
    param([string]$ExtId)
    foreach ($cli in @("code", "codium")) {
        if (Get-Command $cli -ErrorAction SilentlyContinue) {
            $exts = & $cli --list-extensions 2>$null
            if ($exts -match $ExtId) { return $true }
        }
    }
    return $false
}

function Detect-Tool {
    param([string]$Key)
    switch ($Key) {
        "claude_code" {
            if (Get-Command "claude" -ErrorAction SilentlyContinue) { return "binary" }
            if (Test-Path "$env:USERPROFILE\.claude") { return "~\.claude\" }
        }
        "gemini" {
            if (Get-Command "gemini" -ErrorAction SilentlyContinue) { return "binary" }
            if (Test-Path "$env:USERPROFILE\.gemini") { return "~\.gemini\" }
        }
        "codex" {
            if (Get-Command "codex" -ErrorAction SilentlyContinue) { return "binary" }
            if (Test-Path "$env:USERPROFILE\.codex") { return "~\.codex\" }
        }
        "cursor" {
            if (Test-Path "$env:LOCALAPPDATA\Programs\Cursor\Cursor.exe") { return "app" }
            if (Get-Command "cursor" -ErrorAction SilentlyContinue) { return "binary" }
        }
        "windsurf" {
            if (Test-Path "$env:LOCALAPPDATA\Programs\Windsurf\Windsurf.exe") { return "app" }
            if (Get-Command "windsurf" -ErrorAction SilentlyContinue) { return "binary" }
        }
        "cline" {
            if (Test-VscodeExt "saoudrizwan.claude-dev") { return "vscode ext" }
        }
        "roo" {
            if (Test-Path "$env:USERPROFILE\.roo") { return "~\.roo\" }
            if (Test-VscodeExt "rooveterinaryinc.roo-cline") { return "vscode ext" }
        }
        "copilot" {
            if (Test-VscodeExt "GitHub.copilot") { return "vscode ext" }
        }
        "aider" {
            if (Get-Command "aider" -ErrorAction SilentlyContinue) { return "binary" }
        }
        "continue" {
            if (Test-Path "$env:USERPROFILE\.continue") { return "~\.continue\" }
            if (Test-VscodeExt "Continue.continue") { return "vscode ext" }
        }
        "kilo" {
            if (Test-VscodeExt "kilocode.kilo-code") { return "vscode ext" }
        }
        "zed" {
            if (Get-Command "zed" -ErrorAction SilentlyContinue) { return "binary" }
        }
        "opencode" {
            if (Get-Command "opencode" -ErrorAction SilentlyContinue) { return "binary" }
            if (Test-Path "$env:USERPROFILE\.config\opencode") { return "~\.config\opencode\" }
        }
        "antigravity" {
            if (Get-Command "antigravity" -ErrorAction SilentlyContinue) { return "binary" }
        }
    }
    return $null
}

$Tools = @(
    @{ Name="Claude Code";     Key="claude_code"; Type="global" },
    @{ Name="Gemini CLI";      Key="gemini";      Type="global" },
    @{ Name="Codex CLI";       Key="codex";       Type="perrun" },
    @{ Name="Cursor";          Key="cursor";      Type="project" },
    @{ Name="Windsurf";        Key="windsurf";    Type="project" },
    @{ Name="Cline";           Key="cline";       Type="project" },
    @{ Name="Roo Code";        Key="roo";         Type="project" },
    @{ Name="GitHub Copilot";  Key="copilot";     Type="project" },
    @{ Name="Aider";           Key="aider";       Type="perrun" },
    @{ Name="Continue.dev";    Key="continue";    Type="project" },
    @{ Name="Kilo Code";       Key="kilo";        Type="project" },
    @{ Name="Zed";             Key="zed";         Type="project" },
    @{ Name="OpenCode";        Key="opencode";    Type="global" },
    @{ Name="Antigravity";     Key="antigravity"; Type="project" }
)

Write-Header

Write-Section "[1/4] Detecting tools"
$Detected = @()
foreach ($tool in $Tools) {
    $result = Detect-Tool -Key $tool.Key
    if ($result) {
        Write-Detected -Name $tool.Name -Detail $result
        $Detected += @{ Tool = $tool; Result = $result }
    } else {
        Write-Missing -Name $tool.Name
    }
}

if ($Detected.Count -eq 0) {
    Write-Section "[2/4] Installed"
    Write-Host "    ${YELLOW}No supported tools were detected.${RESET}"
    Write-Host "    Inspect the payload here: ${WHITE}$ScriptDir${RESET}"
    Write-Host ""
    exit 0
}

Write-Section "[2/4] Choose install targets"
if ($Yes) {
    Write-Host "    ${GREEN}Installing all $($Detected.Count) detected target(s).${RESET}"
} else {
    Write-Host "    [a] all detected"
    Write-Host "    [c] custom path only"
    for ($i = 0; $i -lt $Detected.Count; $i++) {
        $n = $i + 1
        $name = $Detected[$i].Tool.Name
        $detail = $Detected[$i].Result
        Write-Host "    [$n] $name ($detail)"
    }

    Write-Host ""
    $pick = Read-Host "    choice [a]"
    if (-not $pick) { $pick = "a" }

    switch -regex ($pick) {
        "^[aA]$" { }
        "^[cC]$" { $Detected = @() }
        "^[nNqQ]$" { exit 0 }
        "^\d+$" {
            $idx = [int]$pick - 1
            if ($idx -ge 0 -and $idx -lt $Detected.Count) {
                $Detected = @($Detected[$idx])
            } else {
                Write-Host ""
                Write-Host "${RED}Invalid choice.${RESET}"
                exit 1
            }
        }
        default {
            Write-Host ""
            Write-Host "${RED}Invalid choice.${RESET}"
            exit 1
        }
    }
}

$GlobalTools = $Detected | Where-Object { $_.Tool.Type -in @("global", "perrun") }
$ProjectTools = $Detected | Where-Object { $_.Tool.Type -eq "project" }
$ProjectDir = ""

if ($ProjectTools.Count -gt 0) {
    Write-Host ""
    Write-Host "    Project-level targets need a project path."
    if (-not $Yes) {
        $ProjectDir = Expand-UserPath (Read-Host "    path (Enter to skip)")
    }

    if ($ProjectDir -and -not (Test-Path $ProjectDir)) {
        Write-Host "    ${YELLOW}Skipping project-level targets: path not found.${RESET}"
        $ProjectDir = ""
    }
}

Write-Section "[3/4] Installing"
$InstalledCount = 0
$AlreadyCount = 0
$ManualCount = 0
$SkippedCount = 0

foreach ($item in $GlobalTools) {
    switch ($item.Tool.Key) {
        "claude_code" {
            $dest = Join-Path $env:USERPROFILE ".claude\skills\snitch"
            Write-Action -Name "Claude Code" -Detail "copying payload to ~\.claude\skills\snitch\"
            New-Item -ItemType Directory -Force -Path $dest | Out-Null
            Copy-Item $SkillFile -Destination (Join-Path $dest "SKILL.md") -Force
            $catDest = Join-Path $dest "categories"
            if (Test-Path $catDest) { Remove-Item $catDest -Recurse -Force }
            Copy-Item $CategoriesDir -Destination $catDest -Recurse -Force
            Copy-Extras -Dest $dest
            $InstalledCount++
            Write-Result -Color $GREEN -Prefix "ok" -Name "Claude Code" -Detail "~\.claude\skills\snitch\"
        }
        "gemini" {
            $target = Join-Path $env:USERPROFILE ".gemini\instructions.md"
            Write-Action -Name "Gemini CLI" -Detail "appending instructions in ~\.gemini\instructions.md"
            $result = Append-SkillToFile -Target $target
            if ($result -eq "already_installed") {
                $AlreadyCount++
                Write-Result -Color $YELLOW -Prefix "--" -Name "Gemini CLI" -Detail "already in ~\.gemini\instructions.md"
            } else {
                $InstalledCount++
                Write-Result -Color $GREEN -Prefix "ok" -Name "Gemini CLI" -Detail "~\.gemini\instructions.md"
            }
        }
        "codex" {
            $ManualCount++
            Write-Result -Color $CYAN -Prefix "->" -Name "Codex CLI" -Detail "manual setup: codex --instructions $SkillFile"
        }
        "aider" {
            $ManualCount++
            Write-Result -Color $CYAN -Prefix "->" -Name "Aider" -Detail "manual setup: aider --read $SkillFile"
        }
        "opencode" {
            $dest = Join-Path $env:USERPROFILE ".config\opencode\commands"
            Write-Action -Name "OpenCode" -Detail "copying payload to ~\.config\opencode\commands\"
            New-Item -ItemType Directory -Force -Path $dest | Out-Null
            Copy-Item $SkillFile -Destination (Join-Path $dest "snitch-audit.md") -Force
            $catDest = Join-Path $dest "categories"
            if (Test-Path $catDest) { Remove-Item $catDest -Recurse -Force }
            Copy-Item $CategoriesDir -Destination $catDest -Recurse -Force
            Copy-Extras -Dest $dest
            $InstalledCount++
            Write-Result -Color $GREEN -Prefix "ok" -Name "OpenCode" -Detail "~\.config\opencode\commands\snitch-audit.md"
        }
    }
}

if ($ProjectDir) {
    foreach ($item in $ProjectTools) {
        switch ($item.Tool.Key) {
            "cursor" {
                $dest = Join-Path $ProjectDir ".cursor\rules"
                Write-Action -Name "Cursor" -Detail "copying payload to $dest\"
                Copy-SkillDir -Dest $dest
                $InstalledCount++
                Write-Result -Color $GREEN -Prefix "ok" -Name "Cursor" -Detail "$dest\"
            }
            "windsurf" {
                $target = Join-Path $ProjectDir ".windsurfrules"
                Write-Action -Name "Windsurf" -Detail "appending instructions in $target"
                $result = Append-SkillToFile -Target $target
                if ($result -eq "already_installed") {
                    $AlreadyCount++
                    Write-Result -Color $YELLOW -Prefix "--" -Name "Windsurf" -Detail "already in .windsurfrules"
                } else {
                    $InstalledCount++
                    Write-Result -Color $GREEN -Prefix "ok" -Name "Windsurf" -Detail ".windsurfrules"
                }
            }
            "cline" {
                $target = Join-Path $ProjectDir ".cline\instructions.md"
                Write-Action -Name "Cline" -Detail "appending instructions in $target"
                $result = Append-SkillToFile -Target $target
                if ($result -eq "already_installed") {
                    $AlreadyCount++
                    Write-Result -Color $YELLOW -Prefix "--" -Name "Cline" -Detail "already in .cline\instructions.md"
                } else {
                    $InstalledCount++
                    Write-Result -Color $GREEN -Prefix "ok" -Name "Cline" -Detail ".cline\instructions.md"
                }
            }
            "roo" {
                $dest = Join-Path $ProjectDir ".roo\rules"
                Write-Action -Name "Roo Code" -Detail "copying payload to $dest\"
                Copy-SkillDir -Dest $dest
                $InstalledCount++
                Write-Result -Color $GREEN -Prefix "ok" -Name "Roo Code" -Detail "$dest\"
            }
            "copilot" {
                $target = Join-Path $ProjectDir ".github\copilot-instructions.md"
                Write-Action -Name "GitHub Copilot" -Detail "appending instructions in $target"
                $result = Append-SkillToFile -Target $target
                if ($result -eq "already_installed") {
                    $AlreadyCount++
                    Write-Result -Color $YELLOW -Prefix "--" -Name "GitHub Copilot" -Detail "already in .github\copilot-instructions.md"
                } else {
                    $InstalledCount++
                    Write-Result -Color $GREEN -Prefix "ok" -Name "GitHub Copilot" -Detail ".github\copilot-instructions.md"
                }
            }
            "continue" {
                $dest = Join-Path $ProjectDir ".continue"
                Write-Action -Name "Continue.dev" -Detail "copying payload to $dest\"
                Copy-SkillDir -Dest $dest
                $InstalledCount++
                Write-Result -Color $GREEN -Prefix "ok" -Name "Continue.dev" -Detail "$dest\"
            }
            "kilo" {
                $dest = Join-Path $ProjectDir ".kilocode\rules"
                Write-Action -Name "Kilo Code" -Detail "copying payload to $dest\"
                Copy-SkillDir -Dest $dest
                $InstalledCount++
                Write-Result -Color $GREEN -Prefix "ok" -Name "Kilo Code" -Detail "$dest\"
            }
            "zed" {
                $dest = Join-Path $ProjectDir ".rules"
                Write-Action -Name "Zed" -Detail "copying payload to $dest\"
                Copy-SkillDir -Dest $dest
                $InstalledCount++
                Write-Result -Color $GREEN -Prefix "ok" -Name "Zed" -Detail "$dest\"
            }
            "antigravity" {
                $dest = Join-Path $ProjectDir ".antigravity\skills"
                Write-Action -Name "Antigravity" -Detail "copying payload to $dest\"
                Copy-SkillDir -Dest $dest
                $InstalledCount++
                Write-Result -Color $GREEN -Prefix "ok" -Name "Antigravity" -Detail "$dest\"
            }
        }
    }
} elseif ($ProjectTools.Count -gt 0) {
    $SkippedCount++
    Write-Result -Color $YELLOW -Prefix "--" -Name "Project targets" -Detail "skipped: no project path provided"
}

if (-not $Yes) {
    Write-Host ""
    $CustomDir = Expand-UserPath (Read-Host "    copy payload to another directory? (path or Enter to skip)")
    if ($CustomDir) {
        if (-not (Test-Path $CustomDir)) {
            $create = Read-Host "    create directory? [Y/n]"
            if ($create -notmatch "^[nN]") {
                New-Item -ItemType Directory -Force -Path $CustomDir | Out-Null
            } else {
                $CustomDir = ""
            }
        }

        if ($CustomDir) {
            Write-Action -Name "Custom copy" -Detail "copying payload to $CustomDir\"
            Copy-ManualDir -Dest $CustomDir
            $InstalledCount++
            Write-Result -Color $GREEN -Prefix "ok" -Name "Custom copy" -Detail "$CustomDir\"
        }
    }
}

Write-Section "[4/4] Installed"
Write-Host "    ${DARK}Installed:${RESET} $InstalledCount"
Write-Host "    ${DARK}Already present:${RESET} $AlreadyCount"
Write-Host "    ${DARK}Manual setup notes:${RESET} $ManualCount"
Write-Host "    ${DARK}Skipped:${RESET} $SkippedCount"
Write-Host "    ${DARK}Payload source:${RESET} $ScriptDir"
Write-Host ""
