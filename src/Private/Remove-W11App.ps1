function Remove-W11App {
    <#
    .SYNOPSIS
        Removes a single application (AppX or WinGet).
        Respects DryRun and Critical flags.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$App,

        [Parameter(Mandatory = $true)]
        [bool]$DryRun,
        
        [Parameter(Mandatory = $false)]
        [string]$LogPath
    )

    Write-Log -Message "Processing removal for: $($App.Name)" -Path $LogPath

    Write-Host "Processing removal for: $($App.Name)" -NoNewline

    if ($App.IsCritical) {
        Write-Host " [CRITICAL APP DETECTED]" -ForegroundColor Magenta
        
        if ($DryRun) {
            Write-Host "DryRun: Would prompt user for confirmation here." -ForegroundColor Yellow
            Write-Log -Message "DRYRUN: $($App.Name) is critical." -Path $LogPath -Level "WARN"
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
    }
    catch {
        Write-Error "FAILED to remove $($App.Name). Error: $_"
        Write-Log -Message "ERROR: Failed to remove $($App.Name). Details: $_" -Path $LogPath -Level "ERROR"
    }
}