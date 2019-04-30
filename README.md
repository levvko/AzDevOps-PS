# PowerShell module for management of Azure DevOps projects



## MVP 
### MVP flow
1. Create a project.
2. Create a repo as a clone of public one (2 repos: infa and code).
3. Create release definition for infra and execute it.
4. Create build definition for code.
5. Create release definition for code.

### MVP Status

| Task | Status |
| --- | ---|
| Create project | + |
| Create repository | + |
| Create build definition | - |
| Create release definition | - |
| Trigger build | - |
| Trigger release | - |

## Release notes

### v0.0.2
**Git repositories** - Added *-Source* parameter to New-AzDORepository for public repo import

### v0.0.1 
**Projects** - Get, Create and Remove.  
**Git repositories** - Get, Create, Remove.  
**Builds** - dummy untested functions.  
