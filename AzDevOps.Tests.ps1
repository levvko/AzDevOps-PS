<#
Tests require a config.ps1 file in the module directory.
File should have the following content:

$Token = %YourPersonalAccessToken(PAC)%
$Org = %YourOrgName%
$User = %YourPACName%
$PorjectName = %YourProjectName%

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
    It "Creates a project and waits for 10 seconds" {
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
    #Make sure to switch to the main project
    Connect-AzDOProject -User $User -Token $Token -Organization $Org -Project $ProjectName

    It "Lists repositories" {
        Get-AzDORepository | `
            Should -Not -BeNullOrEmpty;
    }
    It "Fails to get a non-existent repository" {
        { Get-AzDORepository -Name $guid } | `
            Should -Throw 'Repository not found';
    }
    It "Creates a new repository" {
        New-AzDORepository -Name $guid -Source $PublicRepo | `
            Should -Not -BeNullOrEmpty;
    }
    It "Gets created repository" {
        Get-AzDORepository -Name $guid | Select-Object -ExpandProperty name | `
            Should -Be $guid;
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
Describe "Library functions" {
    #Make sure to switch to the main project
    Connect-AzDOProject -User $User -Token $Token -Organization $Org -Project $ProjectName

    It "Lists variable groups" {
        Get-AzDOVarGroup | `
            Should -Not -BeNullOrEmpty;
    }
    It "Fails to get a non-existent variable group" {
        { Get-AzDOVarGroup -Name $guid } | `
            Should -Throw 'Variable Group not found';
    }
    It "Creates a new variable group" {
        New-AzDOVariable -VariableGroupName $guid -Name 'var1' -Value '12345' | `
            Should -Not -BeNullOrEmpty;
    }
    It "Gets created variable group" {
        Get-AzDOVarGroup -Name $guid | Select-Object -ExpandProperty name | `
            Should -Be $guid;
    }
    It "Adds plaintext variable" {
        New-AzDOVariable -VariableGroupName $guid -Name 'var2' -Value '12345' | `
            Should -Not -BeNullOrEmpty;
    }
    It "Adds secret variable" {
        New-AzDOVariable -VariableGroupName $guid -Name 'var3' -Value '12345' -Secret | `
            Should -Not -BeNullOrEmpty;
    }
    It "Fails to create a variable group with the same name" {
        { New-AzDOVarGroup -Name $guid } | `
            Should -Throw;
    }
    It "Fails to remove non-existing variable group" {
        { Remove-AzDOVarGroup -Name $guid_other } | `
            Should -Throw;
    }
    It "Removes variable group" {
        { Remove-AzDOVarGroup -Name $guid } | `
            Should -Not -Throw;
    }
    It "Fails to get removed variable group" {
        { Get-AzDOVarGroup -Name $guid } | `
            Should -Throw;
    }
}
Describe "Build functions" {
    #Make sure to switch to the main project
    
}
Describe "Release functions" {

}

Remove-Module $moduleName
