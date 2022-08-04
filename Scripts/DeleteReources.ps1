# Change the path
$tfFilePath = "E:\Udacity-Bosch-Devops\WebServerProject\Configurations"
Push-Location $tfFilePath

# Destroy
Write-Output "Destroy The Infrastructure"
terraform destroy -auto-approve