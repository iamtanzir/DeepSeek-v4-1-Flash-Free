# Read-only diagnostics for Windows. Nothing here changes your system.
$ErrorActionPreference = 'Continue'
$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

$fail = $false
function Section([string]$Name) { Write-Host "`n$Name" -ForegroundColor Cyan }
function Pass([string]$Text) { Write-Host "  [ok] $Text" -ForegroundColor Green }
function Bad([string]$Text) { Write-Host "  [!!] $Text" -ForegroundColor Red; $script:fail = $true }
function Note([string]$Text) { Write-Host "  [--] $Text" -ForegroundColor Yellow }

function Get-EnvValue([string]$Key) {
    $path = Join-Path $RootDir '.env'
    if (-not (Test-Path $path)) { return '' }
    foreach ($line in Get-Content $path) {
        if ($line -match "^\s*$([regex]::Escape($Key))\s*=\s*(.*)$") { return $Matches[1].Trim() }
    }
    return ''
}

$ollamaContainer = Get-EnvValue 'OLLAMA_CONTAINER'
if (-not $ollamaContainer) { $ollamaContainer = 'deepseek-ollama' }
$webuiContainer = Get-EnvValue 'WEBUI_CONTAINER'
if (-not $webuiContainer) { $webuiContainer = 'open-webui' }

Section 'Host'
Write-Host "  OS   : $([System.Environment]::OSVersion.VersionString)"
$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
Write-Host "  RAM  : $ram GB"
$gpus = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match 'NVIDIA' }
if ($gpus) { Write-Host "  GPU  : $($gpus.Name -join ', ')" } else { Write-Host '  GPU  : no NVIDIA GPU detected' }
$drive = (Get-Item $RootDir).PSDrive
if ($drive) { Write-Host "  Disk : $([math]::Round($drive.Free / 1GB)) GB free" }

Section 'Docker'
if (Get-Command docker -ErrorAction SilentlyContinue) {
    & docker --version
    & docker info *> $null
    if ($LASTEXITCODE -eq 0) { Pass 'Docker daemon is reachable' } else { Bad 'Docker daemon is not running' }
    & docker compose version *> $null
    if ($LASTEXITCODE -eq 0) { Pass 'Docker Compose v2 is available' } else { Bad 'Docker Compose v2 is missing' }
}
else {
    Bad 'docker is not installed'
}

Section 'Containers'
if (Get-Command docker -ErrorAction SilentlyContinue) {
    & docker ps --format "  {{.Names}}`t{{.Status}}"
    $names = (& docker ps --format '{{.Names}}') -join ' '
    if ($names -match [regex]::Escape($ollamaContainer)) { Pass 'ollama container is running' } else { Bad 'ollama container is not running' }
    if ($names -match [regex]::Escape($webuiContainer)) { Pass 'open-webui container is running' } else { Bad 'open-webui container is not running' }
}
else {
    Bad 'cannot list containers without docker'
}

Section 'Ollama'
if (Get-Command docker -ErrorAction SilentlyContinue) {
    $models = (& docker exec $ollamaContainer ollama list 2>$null) -join "`n"
    if ($LASTEXITCODE -eq 0 -and $models) {
        Pass 'API is reachable inside the container'
        Write-Host $models
        $model = Get-EnvValue 'MODEL'
        if ($model) {
            if ($models -match [regex]::Escape($model)) { Pass "model present: $model" }
            else { Bad "model missing: $model" }
        }
    }
    else {
        Bad "cannot run 'ollama list' in the container"
    }
}

Section 'Ports'
if (Get-Command docker -ErrorAction SilentlyContinue) {
    $binding = (& docker port $ollamaContainer 11434/tcp 2>$null) -join ' '
    if ($binding -match '^127\.0\.0\.1:') { Pass "Ollama is private ($binding)" }
    elseif ($binding) { Bad "Ollama is exposed publicly ($binding). Set OLLAMA_BIND=127.0.0.1 in .env" }
    else { Note 'Ollama port is not published' }
}

Section 'HTTP'
$webPort = Get-EnvValue 'WEBUI_PORT'
if (-not $webPort) { $webPort = '3000' }
try {
    $r = Invoke-WebRequest -Uri "http://127.0.0.1:$webPort/health" -UseBasicParsing -TimeoutSec 5
    if ($r.StatusCode -eq 200) { Pass "Open WebUI http://127.0.0.1:$webPort/health" }
    else { Bad "Open WebUI returned HTTP $($r.StatusCode)" }
}
catch {
    Bad "Open WebUI /health is not answering on port $webPort"
}

Section 'Config'
if (Test-Path (Join-Path $RootDir '.env')) { Pass '.env exists' } else { Bad '.env is missing' }
if (Get-EnvValue 'WEBUI_SECRET_KEY') { Pass 'WEBUI_SECRET_KEY is set' } else { Bad 'WEBUI_SECRET_KEY is empty' }

Write-Host ''
if ($fail) {
    Write-Host 'Some checks failed. See the [!!] lines above.' -ForegroundColor Yellow
    exit 1
}
Write-Host 'No blocking problems found.' -ForegroundColor Green
exit 0
