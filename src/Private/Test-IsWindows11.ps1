function Test-IsWindows11 {
    <#
    .SYNOPSIS
        OS Compatibility Check.

    .DESCRIPTION
        Queries 'Win32_OperatingSystem' via CIM. It confirms compatibility by checking if the 'BuildNumber' is 22000 or higher (the Windows 11 baseline) and ensuring the 'Caption' contains the string "Windows".
    #>
    [CmdletBinding()]
    param()

    $OS = Get-CimInstance -ClassName Win32_OperatingSystem
    
    # Windows 11 build starts from 22000
    # (https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information)
    if ($OS.BuildNumber -ge 22000 -and $OS.Caption -match "Windows") {
        return $true
    }
    
    return $false
}