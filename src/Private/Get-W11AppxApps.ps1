function Get-W11AppxApps {
    <#
    .SYNOPSIS
        Retrieves installed AppX (Microsoft Store) packages.

    .DESCRIPTION
        Wraps the native 'Get-AppxPackage' cmdlet with a '-PackageTypeFilter Main' to ignore framework dependencies and focus only on primary user applications. 
        It transforms the native output into the standardized PSCustomObject format used by this script.
    #>
    [CmdletBinding()]
    param ()

    $Apps = Get-AppxPackage -PackageTypeFilter Main
    $Results = @()

    foreach ($App in $Apps) {
        $Results += [PSCustomObject]@{
            Name    = $App.Name
            Id      = $App.PackageFullName
            Version = $App.Version
            Type    = 'AppX'
            Source  = 'AppxPackage'
        }
    }

    return $Results
}