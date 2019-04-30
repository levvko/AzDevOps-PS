# Main and project functions
function Connect-AzDOProject {
    [CmdletBinding()]
    param(
        [string] $User,
        [string] $Token,
        [string] $Organization,
        [string] $Project
    )

    $uri = "https://dev.azure.com/$Organization/_apis/projects/$Project";
    $Script:authInfo = GetAzDOAuthInfo -User $User -Token $Token;
    try {
        Invoke-RestMethod -Uri $uri `
            -Method 'Get' `
            -ContentType "application/json" `
            -Headers @{Authorization=("Basic {0}" -f $authInfo)} | Out-Null;
        $Script:organization = $Organization;
        $Script:project = $Project;
        Write-Verbose "Successfully connected to project $Project of $Organization";
        $Script:azDOAuthenticated = $True;
        return $True
    }
    catch {
        Write-Host "Failed to connect to Azure DevOps project. Error message:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return $False
    }
}

function Test-AzDOConnection {
    [CmdletBinding()]
    Param ()

    if ($Script:azDOAuthenticated) {
        Write-Verbose "Connected to Azure DevOps `n    Organization: $Organization `n    Project: $Project"
    
        return $true
    } else {
        Write-Verbose "Not connected to Azure DevOps"
        return $False
    }
}

function Get-AzDOProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,ValueFromPipeline = $true)]
        [String]$Name
    )

    $uri = "https://dev.azure.com/$Organization/_apis/projects"
    $response = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'
    if ($Name) {
        $proj = $response.value | Where-Object {$_.name -eq $Name}
        if ($proj) {
            return $proj
        } else {
            Throw 'Project not found'
        }
    } else {
        return $response.value
    }
}

function New-AzDOProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True,ValueFromPipeline = $true)]
        [String]$Name,

        [Parameter(Mandatory = $False)]
        [string]$Description,

        [Parameter(Mandatory = $True)]
        [ValidateSet('Agile', 'Scrum', 'CMMI', 'Basic')]
        [string]$Process
    )

    $uri = "https://dev.azure.com/$Organization/_apis/projects?api-version=5.0"
    $procId = Get-AzDOProcess -Name $Process | Select-Object -ExpandProperty id;
    $requestBody = "{
        'name': '$Name',
        'description': '$Description',
        'visibility': 'Private',
        'capabilities': {
          'versioncontrol': {
            'sourceControlType': 'Git'
          },
          'processTemplate': {
            'templateTypeId': '$procId'
          }
        }
      }"

    $newProj = InvokeAzDOAPIRequest -Uri $uri -Method 'Post' -Body $requestBody

    return $newProj
}

function Remove-AzDOProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True,ValueFromPipeline = $true)]
        [String]$Name
    )

    $projId = Get-AzDOProject -Name $Name | Select-Object -ExpandProperty id;
    $uri = "https://dev.azure.com/$Organization/_apis/projects/$($projId)?api-version=5.0"

    $response = InvokeAzDOAPIRequest -Uri $uri -Method 'Delete'
}

function Get-AzDOProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False,ValueFromPipeline = $true)]
        [String]$Name
    )

    $uri = "https://dev.azure.com/$Organization/_apis/process/processes?api-version=5.0";
    $response = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'
    if ($Name) {
        $process = $response.value | Where-Object {$_.name -eq $Name}
        if ($process) {
            return $process
        } else {
            Throw 'Process not found'
        }
    } else {
        return $response.value
    }
}