function Write-Log {
    <#
    .SYNOPSIS
        Standardized logging utility.

    .DESCRIPTION
        Writes a single line to the specified log file in the format:
        [YYYY-MM-DD HH:MM:SS] [LEVEL] Message
        
        It validates the 'Level' parameter against a set list (INFO, WARN, ERROR, DEBUG) to ensure log consistency.

    .PARAMETER Level
        Severity level of the log. Defaults to 'INFO'.
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