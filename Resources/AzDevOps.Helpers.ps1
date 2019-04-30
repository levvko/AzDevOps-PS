function GetAzDOAuthInfo {
    [CmdletBinding()]
    param (
        [string] $User,
        [string] $Token
    )
    return [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $User,$Token)))
}

function InvokeAzDOAPIRequest {
    [CmdletBinding()]
    param(
        [string] $Uri,
        [string] $Method,
        [object] $Body = $null
    )

    if ($Script:azDOAuthenticated) {
        $response = Invoke-RestMethod -Uri $Uri `
            -Method $Method `
            -ContentType "application/json" `
            -Body $Body `
            -Headers @{Authorization=("Basic {0}" -f $authInfo)};
    } else {
        Throw "Not connected to an Azure DevOps project. Please run Connect-AzDOProject cmdlet."
    }

    return $response
}

function ImportAzDORepository {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string] $Name,

        [Parameter(Mandatory = $True)]
        [string] $Source
    )

    $here = Get-Location
    $tempdirPath = "$here\..\.tempgit"
    New-Item -Path $tempdirPath -ItemType Directory | Set-Location
    git clone $Source
    Get-ChildItem | Foreach-Object { Set-Location $_.FullName }
    git remote set-url origin "https://$User`:$Token@dev.azure.com/$Organization/$Project/_git/$Name"
    git push -u origin --all
    Set-Location $here
    Remove-Item $tempdirPath -Force -Recurse
}