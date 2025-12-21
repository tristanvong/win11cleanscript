function Get-W11InstalledSoftware {
    <#
    .SYNOPSIS
        Retrieves a combined list of installed software from AppX and WinGet.
    #>
    [CmdletBinding()]
    param ()

    Write-Verbose "Detecting installed AppX packages..."
    $Appx = Get-W11AppxApps

    Write-Verbose "Detecting installed WinGet packages..."
    $WinGet = Get-W11WinGetApps

    $Total = $Appx + $WinGet | Sort-Object Name
    
    Write-Verbose "Total applications detected: $($Total.Count)"
    return $Total
}