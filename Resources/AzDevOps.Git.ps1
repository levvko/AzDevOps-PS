# Git functions
function Get-AzDORepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,ValueFromPipeline = $true)]
        [String]$Name,
        [switch] $IncludeHidden
    )

    $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/repositories?api-version=5.0"
    
    if ($IncludeHidden) {
        $uri = "$uri&includeHidden=true"
    }

    $repos = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'

    if ($Name) {
        $repo = $repos.value | Where-Object {$_.Name -eq $Name}
        if ($repo) {
            return $repo
        } else {
            Throw 'Repository not found'
        }
    } else {
        return $repos.value
    }
}

function New-AzDORepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True,ValueFromPipeline = $true)]
        [String]$Name
    )

    $uri = "https://dev.azure.com/$Organization/_apis/git/repositories?api-version=5.0"
    $projectId = Get-AzDOProject -Name $Project | Select-Object -ExpandProperty 'id'
    $requestBody = "{
        'name': '$Name',
        'project': {
            'id': '$projectId'
        }
    }"

    $repo = InvokeAzDOAPIRequest -Uri $uri -Method 'Post' -Body $requestBody

    return $repo
}

function Remove-AzDORepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String]$Name
    )

    $repoId = Get-AzDORepository -Name $Name | Select-Object -ExpandProperty 'id'
    $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/repositories/$($repoId)?api-version=5.0"

    InvokeAzDOAPIRequest -Uri $uri -Method 'Delete'
}

function Get-AzDORepositoryFromRecycleBin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,ValueFromPipeline = $true)]
        [String]$Name
        )
        
    $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/recycleBin/repositories?api-version=5.0-preview.1"
    
    $repos = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'

    if ($Name) {
        $repo = $repos.value | Where-Object {$_.Name -eq $Name}
        if ($repo) {
            return $repo
        } else {
            Throw 'Repository not found'
        }
    } else {
        return $repos.value
    }
}

function Restore-AzDORepositoryFromRecycleBin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String]$Name
    )

    $repoId = Get-AzDORepositoryFromRecycleBin -Name $Name | Select-Object -ExpandProperty 'id'
    $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/recycleBin/repositories/$($repoId)?api-version=5.0-preview.1"
    $requestBody = "{
        'deleted': false
    }"

    $repo = InvokeAzDOAPIRequest -Uri $uri -Method 'PATCH' -Body $requestBody
    return $repo
}

function Remove-AzDORepositoryFromRecycleBin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String]$Name
    )

    $repoId = Get-AzDORepositoryFromRecycleBin -Name $Name | Select-Object -ExpandProperty 'id'
    $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/recycleBin/repositories/$($repoId)?api-version=5.0-preview.1"

    InvokeAzDOAPIRequest -Uri $uri -Method 'Delete'
}
