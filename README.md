# PowerShell module for management of Azure DevOps projects
## MVP 
### MVP flow
1. Create a project.
2. Create a repo as a clone of public one (2 repos: infa and code).
3. Configure Variable Group (for Az connection info)
4. Create release definition for infra and execute it.
5. Create build definition for code.
6. Create release definition for code.

### MVP Status

| Task                      | Status    |
| ---                       | ---       |
| Create project            | +         |
| Create repository         | +         |
| Create var group          | +         |
| Create build definition   | -         |
| Create release definition | -         |
| Trigger build             | -         |
| Trigger release           | -         |

## Release notes
### v0.1.0
Json configuration for project creation. Parameters that can be configured:
- Project Name
- Project description
- Repositories (name and optional source)
- Variable groups with plaintext and secret variables

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
