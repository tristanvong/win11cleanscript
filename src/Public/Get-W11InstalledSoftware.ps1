function Get-W11InstalledSoftware {
    <#
    .SYNOPSIS
        Retrieves a combined list of installed software from AppX and WinGet.

    .DESCRIPTION
        Combines the outputs of 'Get-W11AppxApps' and 'Get-W11WinGetApps' into a single array of objects.
        This provides a standardized list that the rest of the script can filter and process regardless of the installation source.

    .OUTPUTS
        System.Array. An array of PSCustomObjects containing Name, Id, Version, Type, and Source.

    .EXAMPLE
        $AllSoftware = Get-W11InstalledSoftware
        $AllSoftware | Where-Object { $_.Type -eq 'WinGet' }
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