# Git functions
function Get-AzDOBuildDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,ValueFromPipeline = $true)]
        [String] $Name
    )

    $uri = "https://dev.azure.com/$Organization/$Project/_apis/build/definitions?api-version=5.0"

    $buildDefs = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'

    if ($Name) {
        $buildDef = $buildDefs.value | Where-Object {$_.Name -eq $Name}
        if ($buildDef) {
            return $buildDef
        } else {
            Throw 'Build Definition not found'
        }
    } else {
        return $buildDefs.value
    }
}

function New-AzDOBuildDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True,ValueFromPipeline = $true)]
        [String] $Name
    )

    $uri = "https://dev.azure.com/$Organization/$Project/_apis/build/definitions?api-version=5.0"
    $projectId = Get-AzDOProject -Name $Project | Select-Object -ExpandProperty 'id'
    $requestBody = "{
        'name': '$Name',
        'project': {
            'id': '$projectId'
        }
    }"

    $requestBody

    $buildDef = InvokeAzDOAPIRequest -Uri $uri -Method 'Post' -Body $requestBody

    return $null
}

function Remove-AzDOBuildDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String] $Name
    )

    #$repoId = Get-AzDORepository -Name $Name | Select-Object -ExpandProperty 'id'
    $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/definitions/$($repoId)?api-version=5.0"

    #InvokeAzDOAPIRequest -Uri $uri -Method 'Delete'
    Throw 'function not implemented yet'
}
