variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "westeurope"
}

variable "username" {
  description = "Username to access Virtual Machines"
  default     = "syedahmad75"
}

variable "password" {
  description = "Password to access Virtual Machines"
  default     = "Batman@123456789"
}

variable "packerImage" {
  description = "Packer Image ID"
  default     = "/subscriptions/78edc3c6-6f4c-46b2-8fed-9503d6b80433/resourceGroups/packerImageRG/providers/Microsoft.Compute/images/packerImage-UdacityBosch"
}

variable "vmCount" {
  description = "Count to Configure the Number of Virtual Machnies and the Deployment at a Minimum"
  default     = "2"
}

variable "serverName" {
  type    = list(any)
  default = ["server1", "server2"]
}

variable "environment" {
  description = "Default Tag"
  default     = "Dev"
}
variable "createdBy" {
  description = "Default Tag"
  default     = "Syed Ahmad"
}
variable "managedBy" {
  description = "Default Tag"
  default     = "Udacity Devops Team"
}
variable "purpose" {
  description = "Default Tag"
  default     = "Web Server Deployment"
}
variable "colorBand" {
  description = "Default Tag"
  default     = "Green"
}
variable "suffix" {
  description = "Resourcetype-Environment-AzureRegion-Instance, Convention for naming azure Resources"
  default     = "dev-westus-001"
}
variable "storageAccountType" {
  description = "Storage Account Type"
  default     = "Standard_LRS"
}
