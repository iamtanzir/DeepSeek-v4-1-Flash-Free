# One-command wrapper for Windows.
#   .\install.ps1
#   .\install.ps1 -Mode coder
#   .\install.ps1 -Mode flagship -Gpu
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
$setup = Join-Path $PSScriptRoot 'scripts\setup.ps1'
& $setup -Mode $Mode -Local:$Local -Gpu:$Gpu -Yes:$Yes -Model $Model
exit $LASTEXITCODE
