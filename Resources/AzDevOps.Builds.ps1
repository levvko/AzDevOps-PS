# Build functions
function Get-AzDOBuildDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,ValueFromPipeline = $true)]
        [String] $Name
    )

    begin {
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/build/definitions?api-version=5.0"
        $buildDefs = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'
    }
    process {
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
}

function Get-AzDOBuildDefinitionTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,ValueFromPipeline = $true)]
        [String] $Name
    )

    begin {
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/build/definitions/templates?api-version=5.0"
        $buildDefs = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'
    }
    process {
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
}

function New-AzDOBuildDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String] $Name,

        [Parameter(Mandatory = $True)]
        [String] $RepositoryName,

        [Parameter(Mandatory = $False)]
        [String] $Template = 'Empty pipeline'
    )
    
    $uri = "https://dev.azure.com/$Organization/$Project/_apis/build/definitions?api-version=5.1-preview.7"
    $repoId = Get-AzDORepository -Name $RepositoryName | Select-Object -ExpandProperty 'id';
    $template = Get-AzDOBuildDefinitionTemplate -Name $Template;
    $requestBody = "{
        'name': '$Name',
        'repository': {
            'id': '$repoId'
        },
        'process': '1',
        'quality': 'definition'
    }"

    return InvokeAzDOAPIRequest -Uri $uri -Method 'Post' -Body $requestBody;
}

function Remove-AzDOBuildDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String] $Name
    )

    #$repoId = Get-AzDORepository -Name $Name | Select-Object -ExpandProperty 'id'
    #$uri = "https://dev.azure.com/$Organization/$Project/_apis/git/definitions/$($repoId)?api-version=5.0"

    #InvokeAzDOAPIRequest -Uri $uri -Method 'Delete'
    Throw 'function not implemented yet'
}
