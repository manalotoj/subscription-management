# apply resource lock on all storage and datalake accounts
# $subscriptionNameLike - ex. value "*DEV*"
# shamelessly adapted from https://www.devopspertise.com/2020/06/12/microsoft-azure-deploy-resource-locks-using-azure-policy/
function lockResourceGroups($subscriptionNameLike) {
    $subscriptions = Get-AzSubscription | Where-Object{$_.Name -like $subscriptionNameLike}

    foreach ($subscription in $subscriptions) {
        Write-Host "Processing subscription:" $subscription.Name -ForegroundColor Yellow
        Select-AzSubscription -SubscriptionObject $subscription
        $resourceGroups = Get-AzResourceGroup

        foreach ($resourceGroup in $resourceGroups) {
            Write-Host "Processing resource gorup: " $resourceGroup.ResourceGroupName -ForegroundColor Yellow
            Set-AzResourceLock -LockName "Delete" -LockLevel CanNotDelete -LockNotes "Contains resources that should not be deleted" -ResourceGroupName $resourceGroup.ResourceGroupName -Force
        }
    }   
}

# apply resource lock on all storage and datalake accounts
# $subscriptionNameLike - ex. value "*DEV*"
function lockStorageAccounts($subscriptionNameLike) {
    $subscriptions = Get-AzSubscription | Where-Object{$_.Name -like $subscriptionNameLike}

    foreach ($subscription in $subscriptions) {
        Write-Host "Processing subscription:" $subscription.Name -ForegroundColor Yellow
        Select-AzSubscription -SubscriptionObject $subscription
        $resources = Get-AzStorageAccount

        foreach ($resource in $resources) {
            Write-Host "Processing storage account: " $resource.StorageAccountName -ForegroundColor Yellow
            Set-AzResourceLock -LockName "Delete" -LockLevel CanNotDelete -LockNotes "Contains resources that should not be deleted" -ResourceGroupName $resource.ResourceGroupName -ResourceName $resource.StorageAccountName -ResourceType "Microsoft.Storage/storageAccounts"  -Force
            Write-Host $resource.StorageAccountName "now has a lock set" -ForegroundColor Green
        }

        $resources = Get-AzDatalakeStoreAccount
        foreach ($resource in $resources) {
            Write-Host "Processing datalake store: " $resource.Name -ForegroundColor Yellow
            $rgName = $resource[0].Id.split('/')[4]
            Set-AzResourceLock -LockName "Delete" -LockLevel CanNotDelete -LockNotes "Contains resources that should not be deleted" -ResourceGroupName $rgName -ResourceName $resource.Name -ResourceType $resource.Type  -Force
        }
    }
}

# enable soft delete on all storage accounts within matching subscriptions
# $subscriptionNameLike - ex. value "*PROD*"
# $retentionDays - ex. 30
function enableSoftDelete($subscriptionNameLike, $retentionDays) {
    $subscriptions = Get-AzSubscription | Where-Object{$_.Name -like $subscriptionNameLike}

    foreach ($subscription in $subscriptions) {
        Write-Host "Processing subscription:" $subscription.Name -ForegroundColor Yellow
        Select-AzSubscription -SubscriptionObject $subscription
        $resources = Get-AzStorageAccount


        foreach ($resource in $resources) {
            Write-Host "Processing storage account" $resource.StorageAccountName "in resource group" $resource.ResourceGroupName -ForegroundColor Yellow
            $resource | Enable-AzStorageBlobDeleteRetentionPolicy -RetentionDays $retentionDays                 
        }
    }
}   
