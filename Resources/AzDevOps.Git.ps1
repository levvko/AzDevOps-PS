# Git functions
function Get-AzDORepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,ValueFromPipeline = $true)]
        [String] $Name,
        [switch] $IncludeHidden
    )

    begin {
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/repositories?api-version=5.0"
        
        if ($IncludeHidden) {
            $uri = "$uri&includeHidden=true"
        }
        $repos = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'
    }
    process {
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
}

<#
When using -Source parameter, temp directory is created one level higher then current directory.
Git command line tool is required to be installed and configured to run from PowerShell.
#>
function New-AzDORepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True,ValueFromPipeline = $true)]
        [String] $Name,

        [Parameter(Mandatory = $False,ValueFromPipeline = $true)]
        [String] $Source = $null
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
    if ($Source) {
        ImportAzDORepository -Name $Name -Source $Source
    }

    return $repo
}

function Remove-AzDORepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String] $Name
    )

    process {
        $repoId = Get-AzDORepository -Name $Name | Select-Object -ExpandProperty 'id'
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/repositories/$($repoId)?api-version=5.0"

        InvokeAzDOAPIRequest -Uri $uri -Method 'Delete'
    }
}

function Get-AzDORepositoryFromRecycleBin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,ValueFromPipeline = $true)]
        [String] $Name
    )

    begin {
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/recycleBin/repositories?api-version=5.0-preview.1"
        $repos = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'
    }
    process {
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
}

function Restore-AzDORepositoryFromRecycleBin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String] $Name
    )

    process {
        $repoId = Get-AzDORepositoryFromRecycleBin -Name $Name | Select-Object -ExpandProperty 'id'
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/recycleBin/repositories/$($repoId)?api-version=5.0-preview.1"
        $requestBody = "{
            'deleted': false
        }"
    
        $repo = InvokeAzDOAPIRequest -Uri $uri -Method 'PATCH' -Body $requestBody
        return $repo
    }
}

function Remove-AzDORepositoryFromRecycleBin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String] $Name
    )

    process {
        $repoId = Get-AzDORepositoryFromRecycleBin -Name $Name | Select-Object -ExpandProperty 'id'
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/git/recycleBin/repositories/$($repoId)?api-version=5.0-preview.1"
    
        InvokeAzDOAPIRequest -Uri $uri -Method 'Delete'
    }
}
