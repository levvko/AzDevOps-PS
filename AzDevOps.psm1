# exporting all .psm1 files
Get-ChildItem "$PSScriptRoot\Resources\*.ps1" | ForEach-Object {
    . $_.FullName
}
