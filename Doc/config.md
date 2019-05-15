# Project configuration files
Aure Devops project can be configured wwith JSON files.
## Example configuration
```json
{
    "name": "testProject",
    "repositories": [
        {
            "name": "repo"
        },
        {
            "name": "repoFromSource",
            "source": "git://github.com/levvko/AzDevOps-PS.git"
        }
    ],
    "variableGroups": [
        {
            "name": "demoEnv",
            "variables": [
                {
                    "name": "secretVar",
                    "value": "supersecret",
                    "isSecret": true
                },
                {
                    "name": "plainVar",
                    "value": "notasecret",
                    "isSecret": false
                }
            ]
        }
    ]
}
```
