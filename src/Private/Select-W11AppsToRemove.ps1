function Select-W11AppsToRemove {
    <#
    .SYNOPSIS
        Filters installed applications based on Blacklist and Whitelist rules.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$InstalledApps,

        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Config
    )

    $AppsToRemove = @()

    foreach ($App in $InstalledApps) {
        $IsBlacklisted = $false
        foreach ($Rule in $Config.Blacklists.RemoveApps) {
            if ($App.Name -like "*$Rule*" -or $App.Id -like "*$Rule*") {
                $IsBlacklisted = $true
                break
            }
        }

        if ($IsBlacklisted) {
            $IsWhitelisted = $false
            foreach ($Rule in $Config.Whitelists.KeepApps) {
                if ($App.Name -like "*$Rule*" -or $App.Id -like "*$Rule*") {
                    $IsWhitelisted = $true
                    break
                }
            }

            if (-not $IsWhitelisted) {
                Write-Verbose "MATCH: '$($App.Name)' matched removal rule."
                $AppsToRemove += $App
            } else {
                Write-Verbose "KEEP: '$($App.Name)' was matched for removal but is in Whitelist."
            }
        }
    }

    return $AppsToRemove
}