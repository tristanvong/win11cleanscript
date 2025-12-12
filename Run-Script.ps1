$ModulePath = Join-Path -Path $PSScriptRoot -ChildPath "src\Win11Clean.psd1"
Import-Module -Name $ModulePath -Force

$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config\settings.json"
$Config = Get-Content -Path $ConfigPath | ConvertFrom-Json
Invoke-Win11Clean -Verbose:$Config.Settings.Verbose