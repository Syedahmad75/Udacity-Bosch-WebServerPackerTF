# Change the path
$tfFilePath = "E:\Udacity-Bosch-Devops\WebServerProject\Configurations"
Push-Location $tfFilePath

# Validate terraform
Write-Output "Starting pre-deploy steps for the TF resources..."
terraform init
terraform validate
Write-Output "pre-deploy steps for the TF resources finished successfully !"

# Deploy
Write-Output "Starting deploy steps for the TF resources..."
terraform plan -out solution.plan
terraform apply "solution.plan"
Write-Output "Deploy steps for the TF resources finished successfully !"

popd