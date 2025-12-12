function Import-W11Config {
    <#
        .SYNOPSIS
        Imports the settings.json file and returns it as a PowerShell object.

        .DESCRIPTION
        This function reads the json configuration file, converts it to a PowerShell object
        and stores this at the user specified location or by default in the Windows TEMP folder
        (C:\Users\user\AppData\Local\Temp).

        .PARAMETER Path
        The absolute or relative path to the settings.json file.

        .EXAMPLE
        $Config = Import-W11Config -Path ".\config\settings.json"
        Imports the settings and stores them in the $Config variable.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        if (-not (Test-Path -Path $Path)) {
            throw "Configuration file not found at $Path"
        }

        $Content = Get-Content -Path $Path
        $Config = $Content | ConvertFrom-Json

        if ($Config.Settings.LogPath -match "TODO" -or [string]::IsNullOrWhiteSpace($Config.Settings.LogPath)) {
            $Config.Settings.LogPath = Join-Path -Path $env:TEMP -ChildPath "Win11Clean.log"
        }

        return $Config
    }
    catch {
        Write-Error "Error loading configuration: $_"
        throw
    }
}