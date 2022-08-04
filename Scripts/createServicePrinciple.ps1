$servicePrincipalName = "servicePrincpleUdacity"
$roleName = "contributor"
$subscriptionID = $(az account show --query id -o tsv)
# Verify the ID of the active subscription
Write-Output "Using subscription ID $subscriptionID"
$resourceGroup = "packerImageRG"

Write-Output "Creating SP for RBAC with name $servicePrincipalName, with role $roleName and in scopes /subscriptions/$subscriptionID/resourceGroups/$resourceGroup"

#Set Environment Variables to Null
$Env:SUBSCRIPTION_ID = $null
$Env:CLIENT_ID = $null
$Env:CLIENT_SECRET = $null
$Env:TENANT_ID = $null

#Create Service Principle and parse into Json values
$servicePrincipalDetails = az ad sp create-for-rbac -n $servicePrincipalName --role $roleName --scopes /subscriptions/$subscriptionID/resourceGroups/$resourceGroup --query "{client_id: appId, client_secret: password, tenant_id: tenant, display_Name: displayName}" | ConvertFrom-Json

#Get Secret Values from the command and dump into the variables and then store in the environment variables.
$Env:SUBSCRIPTION_ID = $subscriptionID
$Env:CLIENT_ID = $servicePrincipalDetails.client_id
$Env:CLIENT_SECRET = $servicePrincipalDetails.client_secret
$Env:TENANT_ID = $servicePrincipalDetails.tenant_id