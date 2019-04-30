<#
Tests require a config.ps1 file in the module directory.
File should have the following content:

$Token = %YourPersonalAccessToken(PAC)%
$Org = %YourOrgName%
$User = %YourPACName%
$PorjectName = %YourProjectName%
$Repository = %YourRepoName%

#>
. "$PSScriptRoot\config.ps1"
$moduleName = 'AzDevOps'
$modulePath = "$PSScriptRoot\$moduleName.psd1"
Import-Module $modulePath
Connect-AzDOProject -User $User -Token $Token -Organization $Org -Project $ProjectName

#generate random guids
$guid = [guid]::newguid().ToString();
$guid_other = [guid]::newguid().ToString();
$guid_proj = [guid]::newguid().ToString().Replace('-','').Substring(0,10);



Describe "Main and project functions" {
    It "Connects to Azure DevOps" {
        Connect-AzDOProject -User $User -Token $Token -Organization $Org -Project $ProjectName | `
            Should -BeTrue
    }
    It "Tests Azure DevOps connection" {
        Test-AzDOConnection | `
            Should -BeTrue
    }
    It "Lists projects" {
        Get-AzDOProject | `
            Should -Not -BeNullOrEmpty;
    }
    It "Gets defined project" {
        Get-AzDOProject -Name $ProjectName | Select-Object -ExpandProperty name | `
            Should -Be $ProjectName;
    }
    It "Fails to get a non-existent project" {
        { Get-AzDOProject -Name $guid } | `
            Should -Throw 'Project not found';
    }
    It "Creates a project" {
        New-AzDOProject -Name $guid_proj -Description 'Test project from Pester' -Process 'Agile' | `
            Should -Not -BeNullOrEmpty;
    }
    It "Removes a project" {
        Start-Sleep -Seconds 10
        { Remove-AzDOProject -Name $guid_proj } | `
            Should -Not -Throw;
    }
}
Describe "Git functions" {
    It "Lists repositories" {
        Get-AzDORepository | `
            Should -Not -BeNullOrEmpty;
    }
    It "Gets defined repository" {
        Get-AzDORepository -Name $Repository | Select-Object -ExpandProperty name | `
            Should -Be $Repository;
    }
    It "Fails to get a non-existent repository" {
        { Get-AzDORepository -Name $guid } | `
            Should -Throw 'Repository not found';
    }
    It "Creates a new repository" {
        New-AzDORepository -Name $guid | `
            Should -Not -BeNullOrEmpty;
    }
    It "Fails to create a repository with the same name" {
        { New-AzDORepository -Name $guid } | `
            Should -Throw;
    }
    It "Fails to remove non-existing repository" {
        { Remove-AzDORepository -Name $guid_other } | `
            Should -Throw;
    }
    It "Removes new repository" {
        { Remove-AzDORepository -Name $guid } | `
            Should -Not -Throw;
    }
    It "Fails to get removed repository" {
        { Get-AzDORepository -Name $guid } | `
            Should -Throw;
    }
    It "Gets the removed repo from recycle bin" {
        Get-AzDORepositoryFromRecycleBin -Name $guid | `
            Should -Not -BeNullOrEmpty
    }
    It "Restores the repo from recycle bin" {
        Restore-AzDORepositoryFromRecycleBin -Name $guid | `
            Should -Not -BeNullOrEmpty
    }
    It "Removes the repo from recyle bin" {
        { 
            Remove-AzDORepository -Name $guid;
            Remove-AzDORepositoryFromRecycleBin -Name $guid;
        } | Should -Not -Throw;
    }
}
Describe "Build functions" {
    It "Lists build definitions" {
        Get-AzDOBuildDefinition | `
            Should -Not -BeNullOrEmpty;
    }
    It "Creates build definition" {
        New-AzDOBuildDefinition -Name $guid | `
            Should -Not -BeNullOrEmpty;
    }
    It "Removes build definitions" {
        {Remove-AzDOBuildDefinition -name $guid }| `
            Should -Not -Throw;
    }
}

Remove-Module $moduleName
