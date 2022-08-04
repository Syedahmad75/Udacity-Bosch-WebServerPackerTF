#Register the Azure Policy Insights resource provider using Azure PowerShell to validate that your subscription works with the resource provider. 
az provider register --namespace 'Microsoft.PolicyInsights'

#initialize and assign values to variables
$policyName = "tagging-policy"
$displayName = "Deny the creation of resources that do not have tags"
$description = "This policy ensures that all indexed resources in our subscription have tags and deny deployment if they do not."

#Create a policy definition
az policy definition create --name $policyName --display-name=$displayName --description=$description --rules "E:\Udacity-Bosch-Devops\WebServerProject\Configurations\azurepolicy.rules.json" 

#Extract the Azure Policy Definition ID 
$policyDefinationID = az policy definition show --name $policyName | ConvertFrom-Json

#Create a policy definition with Azure Policy Definition ID
$resultCreatePolicy = az policy assignment create --name $policyName  --policy $policyDefinationID.id --display-name=$displayName --description=$description | ConvertFrom-Json
#Check if the policy is created successfully or not
if ($resultCreatePolicy.name -eq $policyName) {
    Write-Host "$policyName Policy is created successfully, details are following" -ForegroundColor Green 
    $resultCreatePolicy
}
else {
    Write-Host "$policyName Policy is not created successfully" -ForegroundColor Red
}


#List all policies
Write-Host "Following are the list of All policies that exists in the subscription" -ForegroundColor Yellow
$listExistingPolicies = az policy assignment list | ConvertFrom-Json
$listExistingPolicies