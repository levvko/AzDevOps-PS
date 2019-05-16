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
        $Script:token = $Token
        $Script:user = $User
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
        [String] $Name
    )

    begin {
        $uri = "https://dev.azure.com/$Organization/_apis/projects"
        $response = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'
    }
    process {
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
}

function New-AzDOProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String] $Name,

        [Parameter(Mandatory = $False)]
        [string] $Description,

        [Parameter(Mandatory = $False)]
        [ValidateSet('Agile', 'Scrum', 'CMMI', 'Basic')]
        [string] $Process = 'Agile'
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
    
    Write-Verbose "Switching context to the new project: $Name";
    $Script:project = $Name;

    return $newProj
}

function Remove-AzDOProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True,ValueFromPipeline = $true)]
        [String] $Name
    )

    process {
        $projId = Get-AzDOProject -Name $Name | Select-Object -ExpandProperty id;
        $uri = "https://dev.azure.com/$Organization/_apis/projects/$($projId)?api-version=5.0"
    
        InvokeAzDOAPIRequest -Uri $uri -Method 'Delete' | Out-Null
    }
}

function Get-AzDOProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False,ValueFromPipeline = $true)]
        [String] $Name
    )

    begin {
        $uri = "https://dev.azure.com/$Organization/_apis/process/processes?api-version=5.0";
        $response = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'
    }
    process {
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
}

function New-AzDOProjectFromConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String] $Path
    )

    $inputObject = Get-Content $Path | ConvertFrom-Json

    try {
        New-AzDOProject -Name $inputObject.Name
        Write-Verbose "10 second delay for project creation"
        Start-Sleep -Seconds 10
    }
    catch {
        if ($_.ErrorDetails.Message -like '*project already exists*') {
            Write-Host "Project already exists, skipping project creation"
            $Script:project = $inputObject.name;
        } else {
            Write-Error $_;
            return
        }
    }

    foreach ($varGroup in $inputObject.variableGroups) {
        foreach ($azdoVar in $varGroup.variables) {
            New-AzDOVariable -VariableGroupName $varGroup.name `
                            -Name $azdoVar.name `
                            -Value $azdoVar.value `
                            -isSecret $azdoVar.isSecret
        }
    }

    foreach ($repo in $inputObject.repositories) {
        try {
            Get-AzDORepository -Name $repo.name | Out-Null
            Write-Host "Repository $($repo.name) already exists, skipping repository creation"
        }
        catch {
            if ($_.Exception.Message -eq 'Repository not found') {
                New-AzDORepository -Name $repo.name -Source $repo.source
            } else {
                Write-Error $_
                return
            }
        }
    }
}
