# Storage resource locks

This repo contains Azure policy definitions and PowerShell functions to:
- apply resource locks on storage accounts and ADLS accounts
- apply resource locks on resource groups
- enable soft delete on storage accounts and ADLS accounts when supported

## Policy Definitions
### Storage_ResourceLock.json
Policy definition can be used to apply **CanNotDelete** lock type on storage accounts and ADLS accounts via policy remediation. When remediation is defined using the same policy, a resource lock is created if it does not already exist.

### How to use the policy
1. Create a policy definition
- Within the Azure portal, search for * Policy *
- within * Policy | Definitions *, click "+ Policy definition"
- Provide values for * BASICS *
- Under * POLICY RULE *, replace the contents of the textbox with the contents of /policies/Storage_ResourceLock.json
- Click save

2. Assign the policy
- Within the Azure portal, search for * Policy *
- In the left menu area, select * Authoring > Assignments *
- Select * Assign Policy *
- In the * Basics * panel:
    - select Scope
    - search for * Policy defintion * created in Step 1
- In the * Remediation * panel:
    - check * create a remediation task *
    - specify desired * Managed identity location *
    - * Policy to remediate * dropdown will populate with policy definition selected in the * Basics * panel
- click * Review + create *, click * create *

Navigate to * Policy > Compliance * to view the compliance state. This will take 10-15 minutes to reflect a status other than * not started *. Within * Policy > Compliance *, click on the policy. Within the policy view, click on * Remediation tasks *. Remediation task(s) will be executed as needed after completion of evaluation.

## PowerShell Functions
/powershell/Utils.ps1 contains the following utility functions:
- lockResourceGroups
- lockStorageAccounts
- enableSoftDelete

### Prerequisites:
- Azure Az module installed
- Logged into Azure using * Connect-AzAccount *

Each function expects a string parameter used as a wildcard string to match the desired subscription(s).

``` powershell
# example invocation
. \Utils.ps1 # loads the functions in memory
lockResourceGroups *DEV* # process all resource groups contained in subscriptions whose subscription name contains the string DEV or dev (case-insensitive)
```

#### lockResourceGroups function
The lockResourceGroups function locks all resource groups in the targeted subscription(s).

** WARNING **: Considerations before applying locks at the resource group level
Refer to [Lock resources to prevent unexpected changes](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources) which includes the following considerations when applying CanNotDelete locks:

- A cannot-delete lock on a resource group prevents Azure Resource Manager from automatically deleting deployments in the history. If you reach 800 deployments in the history, your deployments will fail.
- A cannot-delete lock on the resource group created by Azure Backup Service causes backups to fail. The service supports a maximum of 18 restore points. When locked, the backup service can't clean up restore points. For more information, see Frequently asked questions-Back up Azure VMs.

#### lockStorageAccounts function
The lockStorageAccounts function locks all storage accounts (including ADLS accounts) in the targeted subscription(s). Note that system storage accounts will fail to be locked by design - ex. Databricks storage accounts.

```
# example invocation
# process all storage accounts in the targeted subscription(s)

. \Utils.ps1 # loads the functions in memory
lockStorageAccounts *DEV*
```

##### enableSoftDelte function
Enables soft delete on all storage accounts (including ADLS accounts) in the targeted subscription(s) that support soft delete.

```
# example invocation
# enable soft delete with a retention duration of 30 days on all storage accounts 
# in the targeted subscription(s) that support soft delete

. \Utils.ps1 # loads the functions in memory
enableSoftDelete *DEV* 30
```