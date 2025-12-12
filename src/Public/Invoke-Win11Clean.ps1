function Invoke-Win11Clean {
    <#
    .SYNOPSIS
        The entry point for the Win11Clean automation tool.
    #>
    [CmdletBinding()]
    param (
        [string]$ConfigPath
    )

    Write-Host "Starting Win11Clean" -ForegroundColor Cyan

    if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
        $ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\config\settings.json"
    }
   
    Write-Verbose "Loading configuration from: $ConfigPath"
    
    try {
        $Config = Import-W11Config -Path $ConfigPath
        Write-Verbose "SUCCESS: Configuration loaded!"
        
        Write-Verbose "DryRun Mode is: "
        if ($Config.Settings.DryRun) {
            Write-Verbose "TRUE"
        } else {
            Write-Verbose "FALSE"
        }
        
        Write-Verbose "Blacklist contains $($Config.Blacklists.RemoveApps.Count) apps."
    }
    catch {
        Write-Error "Failure: Could not load config. Error: $_"
    }
}