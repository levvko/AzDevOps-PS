function Get-AzDOVarGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String] $Name
    )

    $uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/variablegroups?api-version=5.0-preview.1"
    $response = InvokeAzDOAPIRequest -Uri $uri -Method 'Get'

    if ($Name) {
        $varGroup = $response.value | Where-Object {$_.Name -eq $Name}
        if ($varGroup) {
            return $varGroup
        } else {
            Throw 'Variable Group not found'
        }
    } else {
        return $response.Value
    }
}
function New-AzDOVariable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String] $Name,

        [Parameter(Mandatory = $True)]
        [String] $VariableGroupName,

        [Parameter(Mandatory = $True)]
        [String] $Value,

        [Parameter(Mandatory = $False)]
        [string] $Description,
        
        [Parameter(ParameterSetName = 'switch')]
        [switch] $Secret,

        [Parameter(ParameterSetName = 'bool', Mandatory = $True)]
        [bool] $isSecret
    )

    try{
        $vg = Get-AzDOVarGroup -Name $VariableGroupName
        $vgVars = (ConvertTo-Json $vg.variables).Trim('{}')
    }
    catch {
        $vg = $null
        Write-Verbose 'Variable group not found. Creating new'
    }
    
    $varJson = "'$Name': {'value': '$Value'"
    if ((($PSCmdlet.ParameterSetName -eq 'switch') -and $Secret) -or (($PSCmdlet.ParameterSetName -eq 'bool') -and $isSecret)) {
        $varJson += ",'isSecret': true"
    }
    $varJson += "}"
    
    if ($vg) {
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/variablegroups/$($vg.id)?api-version=5.0-preview.1"
        $requestBody = ($vg | Select-Object -Property name, description, type | ConvertTo-Json).Trim('}')
        $requestBody += ", variables: { $vgVars , $varJson }}"
        $method = 'Put'
    } else {
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/variablegroups?api-version=5.0-preview.1"
        $requestBody = "{
            'name': '$VariableGroupName',
            'description': '$Description',
            'variables': { $varJson
        }}"
        $method = 'Post'
    }

    $newVG = InvokeAzDOAPIRequest -Uri $uri -Method $method -Body $requestBody
    
    return $newVG
}

function Remove-AzDOVarGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String] $Name
    )

    process {
        $varGroupId = Get-AzDOVarGroup -Name $Name | Select-Object -ExpandProperty 'id'
        $uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/variablegroups/$($varGroupId)?api-version=5.0-preview.1"

        InvokeAzDOAPIRequest -Uri $uri -Method 'Delete'
    }
}
