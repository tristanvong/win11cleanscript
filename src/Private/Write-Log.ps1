function Write-Log {
    <#
    .SYNOPSIS
        Appends a message to a log file with a timestamp.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { return }

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogLine = "[$Time] [$Level] $Message"

    try {
        Add-Content -Path $Path -Value $LogLine -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to write to log file: $_"
    }
}