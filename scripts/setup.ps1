#Requires -Version 5.1
<#
.SYNOPSIS
  DeepSeek Free installer for Windows (Docker Desktop + WSL2).

.EXAMPLE
  .\scripts\setup.ps1
  .\scripts\setup.ps1 -Mode coder
  .\scripts\setup.ps1 -Mode flagship -Gpu
  .\scripts\setup.ps1 -Mode api
#>
[CmdletBinding()]
param(
    [ValidateSet('nano', 'lite', 'coder', 'flagship', 'api')]
    [string]$Mode = 'lite',

    [switch]$Local,
    [switch]$Gpu,
    [switch]$Yes,
    [string]$Model = ''
)

$ErrorActionPreference = 'Stop'
$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

function Write-Step([string]$Message) { Write-Host "==> $Message" -ForegroundColor Cyan }
function Write-Ok([string]$Message) { Write-Host " ok $Message" -ForegroundColor Green }
function Write-Warn2([string]$Message) { Write-Host "warn $Message" -ForegroundColor Yellow }
function Die([string]$Message) {
    Write-Host "fail $Message" -ForegroundColor Red
    exit 1
}

function Get-DotEnvValue([string]$Key) {
    $path = Join-Path $RootDir '.env'
    if (-not (Test-Path $path)) { return '' }
    foreach ($line in Get-Content $path) {
        if ($line -match "^\s*$([regex]::Escape($Key))\s*=\s*(.*)$") {
            return $Matches[1].Trim()
        }
    }
    return ''
}

function Set-DotEnvValue([string]$Key, [string]$Value) {
    $path = Join-Path $RootDir '.env'
    $lines = @()
    if (Test-Path $path) { $lines = @(Get-Content $path) }

    $found = $false
    $output = foreach ($line in $lines) {
        if ($line -match "^\s*$([regex]::Escape($Key))=") {
            $found = $true
            "$Key=$Value"
        }
        else {
            $line
        }
    }
    if (-not $found) { $output = @($output) + "$Key=$Value" }
    if (-not $output) { $output = @() }
    # Always write LF (no CRLF) so the same .env works in WSL/Linux too.
    $text = (($output -join "`n") + "`n")
    [System.IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false)))
    [Environment]::SetEnvironmentVariable($Key, $Value, 'Process')
}

function Import-DotEnv {
    $path = Join-Path $RootDir '.env'
    if (-not (Test-Path $path)) { return }
    foreach ($line in Get-Content $path) {
        if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') {
            $key = $Matches[1]
            $value = $Matches[2].Trim()
            if ($value -match '^"(.*)"$') { $value = $Matches[1] }
            elseif ($value -match "^'(.*)'$") { $value = $Matches[1] }
            [Environment]::SetEnvironmentVariable($key, $value, 'Process')
        }
    }
}

function New-Secret {
    $bytes = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    ($bytes | ForEach-Object { $_.ToString('x2') }) -join ''
}

function Confirm-Action([string]$Question) {
    if ($Yes) { return $true }
    $answer = Read-Host "$Question [y/N]"
    return ($answer -match '^(y|yes)$')
}

function Get-TotalRamGb {
    try {
        $bytes = (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory
        return [math]::Round($bytes / 1GB)
    }
    catch {
        return 0
    }
}

function Get-TotalVramGb {
    try {
        $gpus = Get-CimInstance Win32_VideoController -ErrorAction Stop |
            Where-Object { $_.Name -match 'NVIDIA' -and $_.AdapterRAM -gt 0 }
        if (-not $gpus) { return 0 }
        $sum = ($gpus | Measure-Object -Property AdapterRAM -Sum).Sum
        return [math]::Round($sum / 1GB)
    }
    catch {
        return 0
    }
}

function Get-ModelSizeGb([string]$Name) {
    switch -Wildcard ($Name) {
        '*1.5b*' { return 2 }
        '*deepseek-r1:8b*' { return 7 }
        '*deepseek-coder:6.7b*' { return 5 }
        '*iq1_m*' { return 275 }
        '*q4_k*' { return 440 }
        default { return 20 }
    }
}

# ---------------------------------------------------------------------------
# Resolve model
# ---------------------------------------------------------------------------
$modelDefault = switch ($Mode) {
    'nano' { 'deepseek-r1:1.5b' }
    'lite' { 'deepseek-r1:8b' }
    'coder' { 'deepseek-coder:6.7b-instruct' }
    'flagship' { 'frob/deepseek-v4.1-flash:552b-a8b-1017-ud-iq1_M' }
    'api' { 'deepseek-v4.1-flash' }
}
if ($Model) { $modelDefault = $Model }
$ModelName = $modelDefault
$localMode = [bool]($Local -or $Gpu)

Write-Host ''
Write-Step "DeepSeek Free installer (Windows)"
Write-Step "Mode: $Mode   Model: $ModelName   Local tuning: $localMode   GPU: $($Gpu.IsPresent)"
Write-Host ''

# ---------------------------------------------------------------------------
# Docker
# ---------------------------------------------------------------------------
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Die "Docker Desktop is required: https://www.docker.com/products/docker-desktop/"
}

& docker info *> $null
if ($LASTEXITCODE -ne 0) {
    $desktop = Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'
    if (Test-Path $desktop) {
        Write-Step 'Starting Docker Desktop…'
        Start-Process $desktop | Out-Null
        $ready = $false
        for ($i = 0; $i -lt 60; $i++) {
            Start-Sleep -Seconds 2
            & docker info *> $null
            if ($LASTEXITCODE -eq 0) { $ready = $true; break }
        }
        if (-not $ready) { Die 'Docker Desktop did not start. Open it manually and retry.' }
    }
    else {
        Die 'Docker Desktop is installed but not running.'
    }
}

& docker compose version *> $null
if ($LASTEXITCODE -ne 0) {
    Die 'Docker Compose v2 is missing. Update Docker Desktop.'
}

# ---------------------------------------------------------------------------
# Compose files
# ---------------------------------------------------------------------------
$composeFiles = @('-f', (Join-Path $RootDir 'docker-compose.yml'))
if ($localMode) {
    $composeFiles += @('-f', (Join-Path $RootDir 'docker-compose.local.yml'))
}
if ($Gpu) {
    $composeFiles += @('-f', (Join-Path $RootDir 'docker-compose.gpu.yml'))
}

function Invoke-Compose {
    param([string[]]$ComposeArgs)
    & docker compose @composeFiles @ComposeArgs
    if ($LASTEXITCODE -ne 0) {
        Die "docker compose $($ComposeArgs -join ' ') failed with exit code $LASTEXITCODE"
    }
}

# ---------------------------------------------------------------------------
# .env
# ---------------------------------------------------------------------------
$envPath = Join-Path $RootDir '.env'
if (-not (Test-Path $envPath)) {
    Copy-Item (Join-Path $RootDir '.env.example') $envPath
    Write-Step 'Created .env from .env.example'
}
Import-DotEnv
if (-not (Get-DotEnvValue 'WEBUI_SECRET_KEY')) {
    Set-DotEnvValue 'WEBUI_SECRET_KEY' (New-Secret)
    Write-Ok 'Generated WEBUI_SECRET_KEY'
}
Set-DotEnvValue 'MODEL' $ModelName
Set-DotEnvValue 'OLLAMA_BIND' $(if ($env:OLLAMA_BIND) { $env:OLLAMA_BIND } else { '127.0.0.1' })
Set-DotEnvValue 'WEBUI_PORT' $(if ($env:WEBUI_PORT) { $env:WEBUI_PORT } else { '3000' })
if ($localMode) {
    Set-DotEnvValue 'OLLAMA_KEEP_ALIVE' '24h'
    # .env.example ships 8192; bump that default for local, keep custom values.
    $ctx = if ($env:OLLAMA_CONTEXT_LENGTH) { $env:OLLAMA_CONTEXT_LENGTH } else { '8192' }
    if ($ctx -eq '8192') { $ctx = '32768' }
    Set-DotEnvValue 'OLLAMA_CONTEXT_LENGTH' $ctx
    # "Local" means this machine only. Set WEBUI_BIND=0.0.0.0 in .env for LAN access.
    $bind = if ($env:WEBUI_BIND) { $env:WEBUI_BIND } else { '0.0.0.0' }
    if ($bind -eq '0.0.0.0') { $bind = '127.0.0.1' }
    Set-DotEnvValue 'WEBUI_BIND' $bind
    $port = if ($env:WEBUI_PORT) { $env:WEBUI_PORT } else { '3000' }
    $pub = if ($env:PUBLIC_URL) { $env:PUBLIC_URL } else { '' }
    if (-not $pub -or $pub -eq 'http://localhost:3000') { $pub = "http://localhost:$port" }
    Set-DotEnvValue 'PUBLIC_URL' $pub
}
else {
    Set-DotEnvValue 'OLLAMA_KEEP_ALIVE' '30m'
    Set-DotEnvValue 'OLLAMA_CONTEXT_LENGTH' $(if ($env:OLLAMA_CONTEXT_LENGTH) { $env:OLLAMA_CONTEXT_LENGTH } else { '8192' })
}
Import-DotEnv

$ollamaContainer = if ($env:OLLAMA_CONTAINER) { $env:OLLAMA_CONTAINER } else { 'deepseek-ollama' }

# ---------------------------------------------------------------------------
# Guard rails
# ---------------------------------------------------------------------------
if ($Mode -ne 'api') {
    $needGb = Get-ModelSizeGb $ModelName
    $drive = (Get-Item $RootDir).PSDrive
    $freeGb = if ($drive) { [math]::Round($drive.Free / 1GB) } else { 0 }
    Write-Step "Disk: $freeGb GB free, model needs ~$needGb GB"
    if ($freeGb -lt $needGb) {
        Die "Not enough disk space. Free at least $needGb GB and retry."
    }

    if ($Mode -eq 'flagship') {
        $totalGb = (Get-TotalRamGb) + (Get-TotalVramGb)
        Write-Step "RAM + VRAM: $totalGb GB"
        if ($totalGb -lt 288) {
            Write-Warn2 'DeepSeek-V4.1-Flash IQ1_M needs roughly 288 GB of combined RAM/VRAM.'
            Write-Warn2 "This machine has $totalGb GB. Inference will be unusably slow or OOM."
            if (-not (Confirm-Action 'Continue the ~259 GB download anyway?')) {
                Die 'Aborted. Use -Mode lite, or -Mode api for the real model over the network.'
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Start
# ---------------------------------------------------------------------------
Write-Step 'Starting containers…'
Invoke-Compose -ComposeArgs @('up', '-d')

$ollamaReady = $false
for ($i = 0; $i -lt 90; $i++) {
    & docker exec $ollamaContainer ollama list *> $null
    if ($LASTEXITCODE -eq 0) { $ollamaReady = $true; break }
    Start-Sleep -Seconds 2
}
if (-not $ollamaReady) {
    & docker compose @composeFiles logs --tail 60 ollama
    Die 'Ollama did not become healthy.'
}
Write-Ok 'Ollama is healthy'

# ---------------------------------------------------------------------------
# Model
# ---------------------------------------------------------------------------
if ($Mode -eq 'api') {
    $baseUrl = Get-DotEnvValue 'OPENAI_API_BASE_URL'
    $apiKey = Get-DotEnvValue 'OPENAI_API_KEY'
    if ($env:OPENAI_API_BASE_URL) { $baseUrl = $env:OPENAI_API_BASE_URL; Set-DotEnvValue 'OPENAI_API_BASE_URL' $baseUrl }
    if ($env:OPENAI_API_KEY) { $apiKey = $env:OPENAI_API_KEY; Set-DotEnvValue 'OPENAI_API_KEY' $apiKey }
    if (-not $baseUrl -or -not $apiKey) {
        Die @'
api mode needs a remote endpoint. Add these to .env:

  ENABLE_OPENAI_API=true
  OPENAI_API_BASE_URL=https://ollama.com/v1
  OPENAI_API_KEY=your_key

Then rerun: .\scripts\setup.ps1 -Mode api
'@
    }
    Set-DotEnvValue 'ENABLE_OPENAI_API' 'true'
    Invoke-Compose -ComposeArgs @('up', '-d', '--force-recreate', 'open-webui')
    Write-Ok "Open WebUI now uses $baseUrl"
}
else {
    $installed = (& docker exec $ollamaContainer ollama list 2>$null) -join "`n"
    if ($installed -match [regex]::Escape($ModelName)) {
        Write-Ok "Model already present: $ModelName"
    }
    else {
        Write-Step "Pulling $ModelName (this can take a while)…"
        Invoke-Compose -ComposeArgs @('exec', '-T', 'ollama', 'ollama', 'pull', $ModelName)
        Write-Ok "Model ready: $ModelName"
    }
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
$webPort = if ($env:WEBUI_PORT) { $env:WEBUI_PORT } else { '3000' }
$ollamaPort = if ($env:OLLAMA_PORT) { $env:OLLAMA_PORT } else { '11434' }
Write-Host ''
Write-Step 'Done'
Write-Host "  Open WebUI : http://localhost:$webPort"
Write-Host "  Ollama API : http://127.0.0.1:$ollamaPort/v1"
if ($Mode -ne 'api') { Write-Host "  Model      : $ModelName" }
Write-Host ''
Write-Host '  First visit: create the admin account immediately.'
Write-Host '  Diagnostics: .\scripts\doctor.ps1'
Write-Host ''
