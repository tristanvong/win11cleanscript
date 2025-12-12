$Folders = @(
    (Join-Path -Path $PSScriptRoot -ChildPath 'Private'),
    (Join-Path -Path $PSScriptRoot -ChildPath 'Public')
)

foreach ($Folder in $Folders) {
    if (Test-Path -Path $Folder) {
        $Files = Get-ChildItem -Path $Folder -Filter '*.ps1' -File
        foreach ($File in $Files) {
            try {
                . $File.FullName
            }
            catch {
                Write-Error "Failed to import function $($File.Name): $_"
            }
        }
    }
}

$PublicFunctions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public') -Filter '*.ps1' -File
Export-ModuleMember -Function $PublicFunctions.BaseName