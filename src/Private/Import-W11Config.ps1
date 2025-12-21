function Import-W11Config {
    <#
    .SYNOPSIS
        Loads and validates the JSON configuration.

    .DESCRIPTION
        Reads 'settings.json' and converts it into a PowerShell object.
        (Temporary/TODO: actually make it robust) Special Logic: If 'LogPath' is not set or contains "TODO", it automatically points the logs to the current user's Temp folder ($env:TEMP\Win11Clean.log).

    .PARAMETER Path
        The path to the .json file.
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