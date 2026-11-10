# Local high-end PC profile for Windows.
#
#   .\scripts\local-setup.ps1
#   .\scripts\local-setup.ps1 -Gpu
#   .\scripts\local-setup.ps1 -Mode flagship -Gpu
#
# The flagship model is ~259 GB. On a normal desktop the installer will refuse
# and suggest -Mode lite or -Mode api.
[CmdletBinding()]
param(
    [ValidateSet('nano', 'lite', 'coder', 'flagship', 'api')]
    [string]$Mode = 'lite',
    [switch]$Gpu,
    [switch]$Yes,
    [string]$Model = ''
)

$ErrorActionPreference = 'Stop'
$setup = Join-Path $PSScriptRoot 'setup.ps1'
& $setup -Mode $Mode -Local -Gpu:$Gpu -Yes:$Yes -Model $Model
exit $LASTEXITCODE
