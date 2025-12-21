function Get-W11WinGetApps {
    <#
    .SYNOPSIS
        Retrieves and parses the WinGet application list.

    .DESCRIPTION
        Since WinGet returns data as a text table, this function:
        1. Validates 'winget' exists on the system.
        2. Captures the 'winget list' output as a string.
        3. Uses Regular Expressions (Regex) to parse the columns (Name, Id, Version, Source).
        4. Handles UTF8 encoding to ensure special characters in app names don't break the parser.

    .NOTES
        Requires the App Installer (WinGet) to be installed and available in the System PATH.
    #>
    [CmdletBinding()]
    param ()

    if (-not (Get-Command "winget" -ErrorAction SilentlyContinue)) {
        Write-Warning "WinGet is not installed or not in PATH."
        return $null
    }

    # Force UTF8 encoding to prevent breakage during parsing
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    $RawData = winget list --accept-source-agreements --disable-interactivity | Out-String
    $Lines = $RawData -split "`r`n"
    $DataLines = $Lines | Select-Object -Skip 2
    
    $Results = @()

    foreach ($Line in $DataLines) {
        if ([string]::IsNullOrWhiteSpace($Line)) { continue }

        # skip header lines
        if ($Line -match '^Name\s+Id') { continue }
        if ($Line -match '^-+') { continue }

        # Use regex to grab the data from "winget list" command.
        if ($Line -match '^(?<Name>.+?)\s+(?<Id>[^\s]+)\s+(?<Version>[^\s]+)(\s+(?<Source>\w+))?$') {
            $Results += [PSCustomObject]@{
                Name    = $Matches.Name.Trim()
                Id      = $Matches.Id.Trim()
                Version = $Matches.Version.Trim()
                Type    = 'WinGet'
                Source  = if ($Matches.Source) { $Matches.Source } else { "Unknown" }
            }
        }
    }

    return $Results
}