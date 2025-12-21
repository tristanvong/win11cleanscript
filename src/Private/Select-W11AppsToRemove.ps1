function Select-W11AppsToRemove {
    <#
    .SYNOPSIS
        Filters installed apps against user-defined rules.

    .DESCRIPTION
        Applies logic in three distinct layers to ensure only intended apps are targeted:
        1. Blacklist Match: Checks if the App Name or ID matches any string in 'Blacklists.RemoveApps'.
        2. Whitelist Override: If an app is blacklisted, it checks 'Whitelists.KeepApps'. If a match is found, the app is saved from removal.
        3. Safeguard Tagging: Checks 'Safeguards.CriticalApps'. If matched, the 'IsCritical' property is set to $true, which triggers a manual confirmation prompt during removal.

    .PARAMETER InstalledApps
        The full array of apps returned by 'Get-W11InstalledSoftware'.

    .PARAMETER Config
        The configuration object imported from settings.json.

    .EXAMPLE
        $Targeted = Select-W11AppsToRemove -InstalledApps $List -Config $MyConfig
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
                $IsCritical = $false
                if ($null -ne $Config.Safeguards.CriticalApps) {
                    foreach ($Crit in $Config.Safeguards.CriticalApps) {
                        if ($App.Name -like "*$Crit*" -or $App.Id -like "*$Crit*") {
                            $IsCritical = $true
                            break
                        }
                    }
                }

                $App | Add-Member -NotePropertyName "IsCritical" -NotePropertyValue $IsCritical -Force

                Write-Verbose "MATCH: '$($App.Name)' matched removal rule. Critical: $IsCritical"
                $AppsToRemove += $App
            } else {
                Write-Verbose "KEEP: '$($App.Name)' was matched for removal but is in Whitelist."
            }
        }
    }

    return $AppsToRemove
}