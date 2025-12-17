function Invoke-Win11Clean {
    <#
    .SYNOPSIS
        The entry point for the Win11Clean automation tool.
    #>
    [CmdletBinding()]
    param (
        [string]$ConfigPath
    )

    if (-not (Test-IsWindows11)) {
        Write-Error "CRITICAL: This script is designed for Windows 11 only. Execution stopped."
        return
    }

    Write-Host "Starting Win11Clean" -ForegroundColor Cyan

    if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
        $ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\config\settings.json"
    }
   
    Write-Verbose "Loading configuration from: $ConfigPath"
    
    try {
        $Config = Import-W11Config -Path $ConfigPath
        $LogPath = $Config.Settings.LogPath

        Write-Log -Message "--- Win11Clean Started ---" -Path $LogPath
        Write-Verbose "SUCCESS: Configuration loaded!"
        
        Write-Verbose "Detecting Installed Software..."
        $InstalledApps = Get-W11InstalledSoftware
        
        if ($Config.Settings.Verbose) {
            $InstalledApps | Group-Object Type | ForEach-Object {
                Write-Verbose "Found $($_.Count) apps of type $($_.Name):"
                foreach ($App in $_.Group) {
                    Write-Verbose "    - $($App.Name) [$($App.Version)]"
                }
            }
        }
        
        Write-Host "Detection Complete. Found $($InstalledApps.Count) applications." -ForegroundColor Green
        Write-Log -Message "Detection Complete. Found $($InstalledApps.Count) apps." -Path $LogPath

        Write-Verbose "Checking which Apps to Remove..."
        $TargetedApps = Select-W11AppsToRemove -InstalledApps $InstalledApps -Config $Config
        
        if ($TargetedApps.Count -eq 0) {
            Write-Host "No applications matched your removal list." -ForegroundColor Green
            Write-Log -Message "No apps matched removal list." -Path $LogPath
        } else {
            Write-Host "Found $($TargetedApps.Count) applications to remove:" -ForegroundColor Magenta
            $TargetedApps | Format-Table Name, Id, Type -AutoSize
            Write-Log -Message "Found $($TargetedApps.Count) apps to remove." -Path $LogPath

            if (-not $Config.Settings.DryRun) {
                Write-Host "WARNING: DryRun is FALSE. Starting actual removal in 10 seconds..." -ForegroundColor Red
                Write-Log -Message "DryRun is FALSE. Starting removal..." -Path $LogPath -Level "WARN"
                Start-Sleep -Seconds 10
            } else {
                Write-Host "NOTICE: DryRun is TRUE. No changes will be made." -ForegroundColor Yellow
                Write-Log -Message "DryRun is TRUE." -Path $LogPath
            }

            foreach ($App in $TargetedApps) {
                Remove-W11App -App $App -DryRun $Config.Settings.DryRun -LogPath $LogPath
            }
        }
    }
    catch {
        Write-Error "Failure: Error during execution. Details: $_"
        if ($LogPath) { Write-Log -Message "Failure: $_" -Path $LogPath -Level "ERROR" }
    }
}