function Invoke-W11Undo {
    <#
    .SYNOPSIS
        Restores uninstalled WinGet applications.
    
    .DESCRIPTION
        Reads the Undo JSON file and displays a list of removal "Generations" sorted by date.
        The user is prompted to choose a point to restore back to. Reinstallation is performed
        sequentially using WinGet for all generations newer than the target point.

    .PARAMETER UndoPath
        The path to the JSON file containing the removal history.

    .EXAMPLE
        Invoke-W11Undo -UndoPath "$env:TEMP\Win11CleanUndo.json"
        Prompts the user to select a restoration point and reinstalls relevant applications via WinGet.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$UndoPath
    )

    if (-not (Test-Path -Path $UndoPath)) {
        Write-Warning "No undo history found at $UndoPath"
        return
    }

    $History = @(Get-Content -Path $UndoPath | ConvertFrom-Json | Sort-Object Generation -Descending)
    
    Write-Host "--- Win11Clean Undo History (WinGet Only) ---" -ForegroundColor Cyan
    Write-Host "Gen: 0 | Initial State (Restore everything in history)"
    
    foreach ($Gen in $History) {
        $AppList = @($Gen.Apps)
        Write-Host "Gen: $($Gen.Generation) | Date: $($Gen.Date) | Apps: $($AppList.Count)"
        foreach ($App in $AppList) { Write-Host "  - $($App.Name)" -ForegroundColor Gray }
    }

    $TargetGen = Read-Host "Restore back to which Generation? (Enter number, or 'q' to quit)"
    if ($TargetGen -eq 'q' -or [string]::IsNullOrWhiteSpace($TargetGen)) { return }

    # Identify generations to reinstall (everything newer than the target point)
    $ToUndo = $History | Where-Object { [int]$_.Generation -gt [int]$TargetGen }

    if (-not $ToUndo) {
        Write-Host "Nothing to restore for this generation." -ForegroundColor Yellow
        return
    }

    foreach ($Session in $ToUndo) {
        Write-Host "`nRestoring Generation $($Session.Generation)..." -ForegroundColor Magenta
        foreach ($App in @($Session.Apps)) {
            Write-Host "Reinstalling: $($App.Name)... " -NoNewline
            
            $Arguments = @("install", "--id", $App.Id, "--silent", "--accept-package-agreements", "--accept-source-agreements")
            $Process = Start-Process -FilePath "winget" -ArgumentList $Arguments -PassThru -Wait -NoNewWindow
            
            if ($Process.ExitCode -eq 0) { Write-Host "[SUCCESS]" -ForegroundColor Green }
            else { Write-Host "[FAILED: $($Process.ExitCode)]" -ForegroundColor Red }
        }
    }

    # Remove the restored generations from the JSON file
    $RemainingHistory = $History | Where-Object { [int]$_.Generation -le [int]$TargetGen } | Sort-Object Generation
    $RemainingHistory | ConvertTo-Json -Depth 4 | Out-File -FilePath $UndoPath -Force
    Write-Host "`nUndo complete. State restored to Generation $TargetGen." -ForegroundColor Cyan
}