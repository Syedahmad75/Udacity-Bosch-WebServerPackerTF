#Deploy the ResourceGroup if it's not created 
$resourceGroupName = "packerImageRG"
$location = "westEurope"
$tags = "webServerDeployment"
#check if the ResourceGroup already created
$isResourceGroupExists = az group exists --name $resourceGroupName

if ($isResourceGroupExists -eq $true) {
    Write-Host "ResourceGroup is already created with name $resourceGroupName" -ForegroundColor Yellow 
}

#If the ResourceGroup is not already created, create a new one and validate it
else {
    $result = az group create --name $resourceGroupName --location $location --tags $tags --output json | ConvertFrom-Json
    #$Values = $Result | ConvertFrom-Json
    if ($result.name -eq $resourceGroupName) {
        Write-Host "ResourceGroup is created, details are following" -ForegroundColor Green 
        $result
    }
}
