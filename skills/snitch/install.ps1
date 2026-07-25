[CmdletBinding()]
param(
    [switch]$Yes,
    [switch]$NoColor,
    [string]$Project
)

$ErrorActionPreference = "Stop"

$UseColor = (-not $NoColor) -and (-not [Console]::IsOutputRedirected) -and $Host.UI.SupportsVirtualTerminal
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

# On Windows $HOME is %HOMEDRIVE%%HOMEPATH%, which on a domain-joined machine with a
# redirected home is NOT where agents put their dotdirs. Every agent writes under
# %USERPROFILE%. On macOS/Linux USERPROFILE is unset and this falls back to $HOME.
$UserHome = if ($env:USERPROFILE -and (Test-Path -LiteralPath $env:USERPROFILE -PathType Container)) {
    $env:USERPROFILE
} else {
    $HOME
}
$SkillFile = Join-Path $ScriptDir "SKILL.md"
$CategoriesDir = Join-Path $ScriptDir "categories"
$ReferencesDir = Join-Path $ScriptDir "references"
$ComplianceDir = Join-Path $ScriptDir "compliance-templates"
$CustomRulesDir = Join-Path $ScriptDir "custom-rules"
$HooksDir = Join-Path $ScriptDir "hooks"
$ConfigFile = Join-Path $ScriptDir "snitch-security.config.md"

if (-not (Test-Path -LiteralPath $SkillFile)) {
    Write-Host ""
    Write-Host "${RED}error:${RESET} SKILL.md not found in $ScriptDir"
    Write-Host ""
    exit 1
}

if (-not (Test-Path -LiteralPath $CategoriesDir)) {
    Write-Host ""
    Write-Host "${RED}error:${RESET} categories/ not found in $ScriptDir"
    Write-Host ""
    exit 1
}

# Active-category count, sourced from the manifest (single source of truth) so
# it never drifts from what the skill actually scans. The raw *.md file count
# would over-report: it includes _index.md and merged-redirect stubs.
$CatCount = $null
$IndexFile = Join-Path $CategoriesDir "_index.md"
if (Test-Path -LiteralPath $IndexFile) {
    $CatMatch = Select-String -LiteralPath $IndexFile -Pattern 'Active categories:\s*(\d+)' | Select-Object -First 1
    if ($CatMatch) { $CatCount = [int]$CatMatch.Matches[0].Groups[1].Value }
}
if (-not $CatCount) {
    $CatCount = @(Get-ChildItem -LiteralPath $CategoriesDir -File -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -match '^\d+-.*\.md$' }).Count
}
$HasExtras = (Test-Path -LiteralPath $ReferencesDir) -or (Test-Path -LiteralPath $ComplianceDir) -or (Test-Path -LiteralPath $CustomRulesDir) -or (Test-Path -LiteralPath $ConfigFile)

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
    if ($Path -eq "~") { return $UserHome }
    if ($Path.StartsWith("~\") -or $Path.StartsWith("~/")) {
        return (Join-Path $UserHome $Path.Substring(2))
    }
    return $Path
}

function Copy-Extras {
    param([string]$Dest)

    if (Test-Path -LiteralPath $ReferencesDir) {
        $refDest = Join-Path $Dest "references"
        if (Test-Path -LiteralPath $refDest) { Remove-Item -LiteralPath $refDest -Recurse -Force }
        Copy-Item -LiteralPath $ReferencesDir -Destination $refDest -Recurse -Force
    }

    if (Test-Path -LiteralPath $ComplianceDir) {
        $complianceDest = Join-Path $Dest "compliance-templates"
        if (Test-Path -LiteralPath $complianceDest) { Remove-Item -LiteralPath $complianceDest -Recurse -Force }
        Copy-Item -LiteralPath $ComplianceDir -Destination $complianceDest -Recurse -Force
    }

    if (Test-Path -LiteralPath $CustomRulesDir) {
        $rulesDest = Join-Path $Dest "custom-rules"
        if (Test-Path -LiteralPath $rulesDest) { Remove-Item -LiteralPath $rulesDest -Recurse -Force }
        Copy-Item -LiteralPath $CustomRulesDir -Destination $rulesDest -Recurse -Force
    }

    if (Test-Path -LiteralPath $HooksDir) {
        $hooksDest = Join-Path $Dest "hooks"
        if (Test-Path -LiteralPath $hooksDest) { Remove-Item -LiteralPath $hooksDest -Recurse -Force }
        Copy-Item -LiteralPath $HooksDir -Destination $hooksDest -Recurse -Force
    }

    if (Test-Path -LiteralPath $ConfigFile) {
        Copy-Item -LiteralPath $ConfigFile -Destination (Join-Path $Dest "snitch-security.config.md") -Force
    }
}


# Skill directory name, taken from the SKILL.md frontmatter so it can never drift
# from the skill's declared identity.
$SkillSlug = ""
foreach ($line in (Get-Content -LiteralPath $SkillFile)) {
    if ($line -match '^name:\s*([A-Za-z0-9_-]+)') { $SkillSlug = $Matches[1]; break }
}
if (-not $SkillSlug) { $SkillSlug = Split-Path -Leaf $ScriptDir }
if (-not $SkillSlug) {
    Write-Host ""
    Write-Host "${RED}error:${RESET} could not determine skill slug"
    Write-Host ""
    exit 1
}

# Agent registry: Name|global skills dir|detection dir|detection binary
# Paths follow the open agent-skills convention (<agent>/skills/<skill-name>/).
# Regenerate from the ecosystem's published agent table when new agents appear.
$Agents = @(
    "AdaL|~/.adal/skills|~/.adal|"
    "AiderDesk|~/.aider-desk/skills|~/.aider-desk|aider"
    "Amp|~/.config/agents/skills|~/.config/agents|amp"
    "Antigravity|~/.gemini/antigravity/skills|~/.gemini/antigravity|"
    "Antigravity CLI|~/.gemini/antigravity-cli/skills|~/.gemini/antigravity-cli|"
    "AstrBot|~/.astrbot/data/skills|~/.astrbot|"
    "Augment|~/.augment/skills|~/.augment|"
    "Autohand Code CLI|~/.autohand/skills|~/.autohand|"
    "Claude Code|~/.claude/skills|~/.claude|claude"
    "Cline|~/.agents/skills|~/.agents|"
    "Code Studio|~/.codestudio/skills|~/.codestudio|"
    "CodeArts Agent|~/.codeartsdoer/skills|~/.codeartsdoer|"
    "CodeBuddy|~/.codebuddy/skills|~/.codebuddy|"
    "Codemaker|~/.codemaker/skills|~/.codemaker|"
    "Codex|~/.codex/skills|~/.codex|codex"
    "Command Code|~/.commandcode/skills|~/.commandcode|"
    "Continue|~/.continue/skills|~/.continue|"
    "Cortex Code|~/.snowflake/cortex/skills|~/.snowflake/cortex|"
    "Crush|~/.config/crush/skills|~/.config/crush|crush"
    "Cursor|~/.cursor/skills|~/.cursor|cursor"
    "Deep Agents|~/.deepagents/agent/skills|~/.deepagents|"
    "Devin for Terminal|~/.config/devin/skills|~/.config/devin|devin"
    "Dexto|~/.agents/skills|~/.agents|"
    "Droid|~/.factory/skills|~/.factory|droid"
    "Firebender|~/.firebender/skills|~/.firebender|"
    "ForgeCode|~/.forge/skills|~/.forge|forge"
    "Gemini CLI|~/.gemini/skills|~/.gemini|gemini"
    "GitHub Copilot|~/.copilot/skills|~/.copilot|"
    "Goose|~/.config/goose/skills|~/.config/goose|goose"
    "Grok Build|~/.grok/skills|~/.grok|grok"
    "Hermes Agent|~/.hermes/skills|~/.hermes|"
    "IBM Bob|~/.bob/skills|~/.bob|"
    "iFlow CLI|~/.iflow/skills|~/.iflow|iflow"
    "inference.sh|~/.inferencesh/skills|~/.inferencesh|"
    "Jazz|~/.jazz/skills|~/.jazz|"
    "Junie|~/.junie/skills|~/.junie|"
    "Kilo Code|~/.kilocode/skills|~/.kilocode|"
    "Kimchi|~/.config/kimchi/harness/skills|~/.config/kimchi|"
    "Kimi Code CLI|~/.agents/skills|~/.agents|"
    "Kiro CLI|~/.kiro/skills|~/.kiro|kiro"
    "Kode|~/.kode/skills|~/.kode|kode"
    "Lingma|~/.lingma/skills|~/.lingma|"
    "Loaf|~/.agents/skills|~/.agents|"
    "MCPJam|~/.mcpjam/skills|~/.mcpjam|"
    "Mistral Vibe|~/.vibe/skills|~/.vibe|"
    "Moxby|~/.moxby/skills|~/.moxby|"
    "Mux|~/.mux/skills|~/.mux|mux"
    "Neovate|~/.neovate/skills|~/.neovate|"
    "Ona|~/.ona/skills|~/.ona|ona"
    "OpenClaw|~/.openclaw/skills|~/.openclaw|"
    "OpenCode|~/.config/opencode/skills|~/.config/opencode|opencode"
    "OpenHands|~/.openhands/skills|~/.openhands|openhands"
    "Pi|~/.pi/agent/skills|~/.pi|pi"
    "Pochi|~/.pochi/skills|~/.pochi|"
    "Qoder|~/.qoder/skills|~/.qoder|"
    "Qoder CN|~/.qoder-cn/skills|~/.qoder-cn|"
    "Qwen Code|~/.qwen/skills|~/.qwen|qwen"
    "Reasonix|~/.reasonix/skills|~/.reasonix|"
    "Replit|~/.config/agents/skills|~/.config/agents|"
    "Roo Code|~/.roo/skills|~/.roo|"
    "Rovo Dev|~/.rovodev/skills|~/.rovodev|"
    "Tabnine CLI|~/.tabnine/agent/skills|~/.tabnine|"
    "Terramind|~/.terramind/skills|~/.terramind|"
    "Tinycloud|~/.tinycloud/skills|~/.tinycloud|"
    "Trae|~/.trae/skills|~/.trae|trae"
    "Trae CN|~/.trae-cn/skills|~/.trae-cn|"
    "Universal|~/.config/agents/skills|~/.config/agents|"
    "Warp|~/.agents/skills|~/.agents|"
    "Windsurf|~/.codeium/windsurf/skills|~/.codeium/windsurf|windsurf"
    "ZCode|~/.zcode/skills|~/.zcode|"
    "Zed|~/.agents/skills|~/.agents|zed"
    "Zencoder|~/.zencoder/skills|~/.zencoder|"
    "Zenflow|~/.zencoder/skills|~/.zencoder|"
)

# Project-level universal path. Read by Cursor, Codex, Copilot, Gemini CLI, Cline,
# Zed, OpenCode, Antigravity and others, so one directory covers many agents.
$UniversalProjectDir = ".agents/skills"

# Locations earlier versions of this installer wrote to. Never deleted - only
# reported, so an upgrading user knows where a stale copy still sits.
$LegacyPaths = @(".cursor/rules", ".roo/rules", ".kilocode/rules", ".windsurfrules",
                 ".cline/instructions.md", ".github/copilot-instructions.md", ".rules")

function Install-Payload {
    param([string]$Dest)
    # .NET APIs resolve relative paths against the process working directory, not $PWD,
    # and Set-Location does not sync the two. Anchor to an absolute path so
    # CreateDirectory and the Copy-Item cmdlets below cannot disagree about what
    # a relative $Dest means. GetUnresolvedProviderPathFromPSPath works on paths
    # that do not exist yet and does not glob, so it preserves the -LiteralPath intent.
    $Dest = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Dest)
    [void][System.IO.Directory]::CreateDirectory($Dest)
    Copy-Item -LiteralPath $SkillFile -Destination (Join-Path $Dest "SKILL.md") -Force
    $catDest = Join-Path $Dest "categories"
    if (Test-Path -LiteralPath $catDest) { Remove-Item -LiteralPath $catDest -Recurse -Force }
    Copy-Item -LiteralPath $CategoriesDir -Destination $catDest -Recurse -Force
    Copy-Extras -Dest $Dest
}

Write-Header

# ---------------------------------------------------------------- detect
Write-Section "[1/4] Detecting agents"

$Detected = @()
foreach ($entry in $Agents) {
    $f = $entry -split '\|'
    $name = $f[0]; $gdir = $f[1]; $ddir = $f[2]; $bin = $f[3]
    $probe = Expand-UserPath $ddir
    $how = ""
    if ($bin -and (Get-Command $bin -ErrorAction SilentlyContinue)) {
        $how = "binary"
    } elseif (Test-Path -LiteralPath $probe -PathType Container) {
        $how = "$ddir/"
    }
    if ($how) {
        $Detected += [PSCustomObject]@{ Name = $name; GlobalDir = $gdir; How = $how }
    }
}

if ($Detected.Count -gt 0) {
    foreach ($d in $Detected) { Write-Detected $d.Name $d.How }
} else {
    Write-Host "    ${GRAY}No supported agents detected on this machine.${RESET}"
}
Write-Host ""
Write-Host "    ${GRAY}$($Detected.Count) of $($Agents.Count) known agents detected${RESET}"

# ---------------------------------------------------------------- project target
Write-Section "[2/4] Project-level install (optional)"

Write-Host "    ${GRAY}One directory - .agents/skills/ - is read by Cursor, Codex, Copilot,${RESET}"
Write-Host "    ${GRAY}Gemini CLI, Cline, Zed, OpenCode, Antigravity and more.${RESET}"

$Interactive = (-not $Yes) -and (-not [Console]::IsInputRedirected)

$ProjectDir = ""
if ($Project) {
    $ProjectDir = Expand-UserPath $Project
    if (-not (Test-Path -LiteralPath $ProjectDir -PathType Container)) {
        Write-Host "    ${YELLOW}Skipping project install: path not found.${RESET}"
        $ProjectDir = ""
    } else {
        $ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).ProviderPath
    }
} elseif ($Interactive) {
    $reply = Read-Host "    project path (Enter to skip)"
    if ($reply) { $reply = $reply.Trim() }
    if ($reply) {
        $ProjectDir = Expand-UserPath $reply
        if (-not (Test-Path -LiteralPath $ProjectDir -PathType Container)) {
            Write-Host "    ${YELLOW}Skipping project install: path not found.${RESET}"
            $ProjectDir = ""
        } else {
            $ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).ProviderPath
        }
    }
} elseif ($Yes) {
    Write-Host "    ${GRAY}skipped (-Yes)${RESET}"
} else {
    Write-Host "    ${GRAY}skipped (non-interactive)${RESET}"
}

# ---------------------------------------------------------------- install
Write-Section "[3/4] Installing"

$installedCount = 0
$alreadyCount = 0
$seen = @{}

foreach ($d in $Detected) {
    $dest = Join-Path (Expand-UserPath $d.GlobalDir) $SkillSlug
    # Several agents share one skills directory; install once per destination.
    if ($seen.ContainsKey($dest)) {
        Write-Result $GRAY "--" $d.Name "shares a directory already installed"
        continue
    }
    $seen[$dest] = $true
    if (Test-Path -LiteralPath (Join-Path $dest "SKILL.md")) {
        Write-Action $d.Name "updating $($d.GlobalDir)/$SkillSlug/"
        $alreadyCount++
    } else {
        Write-Action $d.Name "installing to $($d.GlobalDir)/$SkillSlug/"
        $installedCount++
    }
    Install-Payload $dest
    Write-Result $GREEN "ok" $d.Name "$($d.GlobalDir)/$SkillSlug/"
}

if ($ProjectDir) {
    $pdest = Join-Path (Join-Path $ProjectDir $UniversalProjectDir) $SkillSlug
    Write-Action "Project" "installing to $UniversalProjectDir/$SkillSlug/"
    Install-Payload $pdest
    Write-Result $GREEN "ok" "Project" "$UniversalProjectDir/$SkillSlug/"
    $installedCount++
}

if (($installedCount -eq 0) -and ($alreadyCount -eq 0)) {
    Write-Host "    ${GRAY}nothing installed${RESET}"
}

# ---------------------------------------------------------------- legacy check
if ($ProjectDir) {
    $legacyFound = @()
    foreach ($lp in $LegacyPaths) {
        if (Test-Path -LiteralPath (Join-Path $ProjectDir $lp)) { $legacyFound += $lp }
    }
    if ($legacyFound.Count -gt 0) {
        Write-Host ""
        Write-Host "    ${YELLOW}Earlier versions installed into rules files. These still exist and may${RESET}"
        Write-Host "    ${YELLOW}hold a stale copy of the skill - review and remove them yourself:${RESET}"
        foreach ($lp in $legacyFound) { Write-Host "      ${GRAY}$lp${RESET}" }
    }
}

# ---------------------------------------------------------------- summary
Write-Section "[4/4] Installed"

$total = $installedCount + $alreadyCount
$word = if ($total -eq 1) { "directory" } else { "directories" }
Write-Host "    ${WHITE}$total${RESET} agent $word written  ${GRAY}($installedCount new, $alreadyCount updated)${RESET}"
Write-Host "    ${DARK}Payload:${RESET} SKILL.md + $CatCount categories + references"
Write-Host ""
Write-Host "    ${GRAY}Ask your agent for a security audit to start a scan.${RESET}"
Write-Host "    ${ACCENT}snitchplugin.com${RESET}"
Write-Host ""
