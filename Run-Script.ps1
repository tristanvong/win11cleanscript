<#
.SYNOPSIS
    Execution wrapper for the Win11Clean module.

.DESCRIPTION
    This script serves as the primary entry point for the user. It performs the following setup:
    1. Locates and imports the Win11Clean module manifest (.psd1).
    2. Loads the 'settings.json' configuration file from the local config directory.
    3. Triggers the main 'Invoke-Win11Clean' function with verbosity settings derived from the JSON config.

.EXAMPLE
    .\Run-Script.ps1
    Runs the full cleanup process using settings defined in config\settings.json.

.NOTES
    This script must be run from the root of the project folder so it can correctly resolve the relative paths to the 'src' and 'config' directories.
#>

$ModulePath = Join-Path -Path $PSScriptRoot -ChildPath "src\Win11Clean.psd1"
Import-Module -Name $ModulePath -Force

$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config\settings.json"
$Config = Get-Content -Path $ConfigPath | ConvertFrom-Json
Invoke-Win11Clean -Verbose:$Config.Settings.Verbose