# PowerShell module for management of Azure DevOps projects
The PowerShell module is a wrapper for selected Azure DevOps API calls. It also contains a tool to create Azure DevOps projects from JSON configuration files.

The main purpose is to quickly setup a project for [Azure DevOps with Azure demo](/Doc/demo.md).

## Release notes
### v0.1.1
Working on documentation

### v0.1.0
Json configuration for project creation. Parameters that can be configured:
* Project Name
* Project description
* Repositories (name and optional source)
* Variable groups with plaintext and secret variables
For more details see [help aprticle](/Doc/config.md)

### v0.0.4
Added Variable group functions.

### v0.0.3
All functions are updated to correctly accept pipeline input, where applicable.

### v0.0.2
**Git repositories** - Added *-Source* parameter to New-AzDORepository for public repo import

### v0.0.1 
**Projects** - Get, Create and Remove.  
**Git repositories** - Get, Create, Remove.  
**Builds** - dummy untested functions.  
