#Delete Packer Images
$resourceGroup="MyResourceGroupName"
$name="myPackerImageName"
az image delete -g $resourceGroup -n $name