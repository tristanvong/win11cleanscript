function Write-W11Undo {
    <#
    .SYNOPSIS
        Records uninstalled WinGet applications to a persistent history file.

    .DESCRIPTION
        Creates or updates a JSON-based history log. Each execution of the cleanup script that successfully 
        removes WinGet applications creates a new "Generation." This function filters for 'WinGet' 
        type applications to ensure stable reinstallation later.

    .PARAMETER RemovedApps
        An array of application objects that were successfully uninstalled during the current session.

    .PARAMETER Path
        The file path where the JSON history (Undo log) will be stored.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$RemovedApps,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Filter to only include WinGet apps for reinstallation support
    $WinGetApps = @($RemovedApps | Where-Object { $_.Type -eq 'WinGet' })
    
    if ($WinGetApps.Count -eq 0) { return }

    $History = @()
    if (Test-Path -Path $Path) {
        $History = @(Get-Content -Path $Path | ConvertFrom-Json)
    }

    # Determine next generation number
    $GenNumber = 1
    if ($History.Count -gt 0) {
        $GenNumber = ($History | Measure-Object -Property Generation -Maximum).Maximum + 1
    }

    $NewEntry = [PSCustomObject]@{
        Generation = $GenNumber
        Date       = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
        Apps       = @($WinGetApps | ForEach-Object { 
            [PSCustomObject]@{ 
                Name = $_.Name; 
                Id   = $_.Id; 
                Type = $_.Type 
            } 
        })
    }

    $History += $NewEntry
    $History | ConvertTo-Json -Depth 4 | Out-File -FilePath $Path -Force
}