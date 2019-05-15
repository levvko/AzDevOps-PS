# Demo 
## Azure DevOps demo plan
- [x] Create a project.
- [x] Create a repo as a clone of public one (2 repos: infa and code).
- [x] Configure Variable Group (for Az connection info).
- [x] Deploy Infrastructure.
- [ ] Build code.
- [ ] Deploy code.

## Comments
### Prerequisites
The demo requires an organization to be already created in Azure DevOps. There should also be a [personal access token configured](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate). After that you should run the `<Connect-AzProject>` to initiate connection to the organization.

### Create project
Project creation can be done with `<New-AzDOProject>` cmdlet ([project functions page](/Doc/projectFunctions.md)) or with configuration files ([configuration files page](/Doc/config.md)). In the case of configuration file usage, repositories and variable groups are created from the same input file.

As soon as a project is created, context is switched to it. All of the cmdlets that are used further do not require (and do not accept) project reference and operate on current Azure DevOps context. To switch context use the `<Connect-AzDOProject>` cmdlet.

### Create repository
Repository creation is done using `<New-AzDoRepository>` cmdlet. In the case of the demo, repositories are created from public repos source (cloned).

Full details can be found on [repository functions](/Doc/repoFunctions.md) page.

### Configure Variable Group
Variable group should be created to store Azure connection information in secret variables. When you create a variable with the `<New-AzDOVariable -VariableGroupsName 'vargroupname' -Name 'var' -Value 'value'>` the **var** variable is added to the **vargroupname** variable group if it exists; a new variable group is created in the other case.

Full details can be found on [variable groups functions](/Doc/varFunctions.md) page.

### Deploy infrastructure
At the moment of the module creation, API capability is very limited. Due to the fact that YAML declarative pipelines are used in the demo, pipeline definition creation is done manually through the portal. It just requires to select the recently created repository and aggree to use the pipeline declaration stored in it.

### Build and deploy code
Multi-stage pipelines are used in the demo. Both build and deploy activities are configured as separate stages of a single pipeline, as well as promotin from one environment to another. 
