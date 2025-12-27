function Remove-W11App {
    <#
    .SYNOPSIS
        Executes the uninstallation of a specific package.

    .DESCRIPTION
        Handles the actual removal of a package using the appropriate provider:
        - AppX: Uses 'Remove-AppxPackage'.
        - WinGet: Uses 'winget uninstall' with silent and auto-agreement flags.
        
        The function includes logic to handle 'IsCritical' apps by pausing for user input ('Y' to confirm) and respects the 'DryRun' global setting to prevent actual system changes during testing.

    .PARAMETER App
        The specific application object to be processed.

    .PARAMETER DryRun
        If $true, the function logs and prints intent but does not run uninstallation commands.

    .PARAMETER LogPath
        The file path where the results of the operation (Success/Fail) are recorded.

    .PARAMETER NoConfirm
        If $true, ignores 'IsCritical' status and proceeds with removal without a manual prompt.

    .OUTPUTS
        System.Boolean. Returns $true if the application was successfully removed from the system.
        Returns $false if removal failed or was skipped (DryRun).
        'Invoke-Win11Clean' uses this result to determine if the app should be added to the Undo log.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$App,

        [Parameter(Mandatory = $true)]
        [bool]$DryRun,
        
        [Parameter(Mandatory = $false)]
        [string]$LogPath,

        [Parameter(Mandatory = $false)]
        [bool]$NoConfirm = $false
    )

    Write-Log -Message "Processing removal for: $($App.Name)" -Path $LogPath

    Write-Host "Processing removal for: $($App.Name)" -NoNewline

    if ($App.IsCritical) {
        Write-Host " [CRITICAL APP DETECTED]" -ForegroundColor Magenta
        
        if ($DryRun) {
            Write-Host "DryRun: Would prompt user for confirmation here." -ForegroundColor Yellow
        } elseif ($NoConfirm) {
            # Bypass the manual "Y" (yes) check
            Write-Host " [NO-CONFIRM ACTIVE: AUTO-APPROVING]" -ForegroundColor Cyan
            Write-Log -Message "NO-CONFIRMATION: $($App.Name) removed due to -NoConfirm switch." -Path $LogPath
        } else {
            $Confirmation = Read-Host "WARNING: This app is marked as Critical. Type 'Y' to confirm deletion"
            if ($Confirmation -ne 'Y') {
                Write-Host "SKIPPED: User declined." -ForegroundColor Gray
                Write-Log -Message "SKIP: User declined removal of $($App.Name)." -Path $LogPath -Level "WARN"
                return
            }
        }
    }

    if ($DryRun) {
        Write-Host " [DRY RUN - NO ACTION TAKEN]" -ForegroundColor Yellow
        Write-Verbose "DryRun: Would have executed removal command for $($App.Type) package."
        Write-Log -Message "DRYRUN: Would remove $($App.Name)" -Path $LogPath
        return
    }

    Write-Host " [REMOVING]" -ForegroundColor Red
    
    try {
        if ($App.Type -eq 'AppX') {
            Write-Verbose "Executing: Remove-AppxPackage -Package $($App.Id)"
            Remove-AppxPackage -Package $App.Id -ErrorAction Stop
        }
        elseif ($App.Type -eq 'WinGet') {
            Write-Verbose "Executing: winget uninstall --id $($App.Id) --silent"
            
            $Process = Start-Process -FilePath "winget" -ArgumentList "uninstall", "--id", $App.Id, "--silent", "--accept-source-agreements" -PassThru -Wait -NoNewWindow
            
            if ($Process.ExitCode -ne 0) {
                throw "WinGet exited with code $($Process.ExitCode)"
            }
        }
        
        Write-Host "SUCCESS: $($App.Name) removed." -ForegroundColor Green
        Write-Log -Message "SUCCESS: Removed $($App.Name)" -Path $LogPath
        return $true
    }
    catch {
        Write-Error "FAILED to remove $($App.Name). Error: $_"
        Write-Log -Message "ERROR: Failed to remove $($App.Name). Details: $_" -Path $LogPath -Level "ERROR"
        return $false
    }
}