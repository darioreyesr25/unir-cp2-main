variable "environment" {
  description = "Deployment environment: dev, pre, pro"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-cnd-cp2"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Canada Central"
}

variable "acr_name" {
  description = "ACR name"
  type        = string
  default     = "acrdevcndcp2"
}

variable "vm_name" {
  description = "Virtual Machine name"
  type        = string
  default     = "vm-cnd-cp2-docs"
}

variable "vm_username" {
  description = "Virtual Machine username"
  type        = string
  default     = "darioreyesr25"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2ls_v2"
}

variable "ssh_public_key" {
  description = "Path to the local ssh public key"
  type        = string
  default     = "C:\\Users\\dario\\.ssh\\id_rsa.pub"
}

# Networking
variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
  default     = "vnet-cnd-cp2"
}

variable "subnet_name" {
  description = "Subnet Name"
  type        = string
  default     = "subnet-cnd-cp2"
}

variable "subnet_cidr" {
  description = "Subnet CIDR Block"
  type        = string
  default     = "10.0.1.0/24"
}

# OS Image
variable "image_os" {
  description = "OS Image SKU"
  type        = string
  default     = "18.04-LTS"
}

# Image offer
variable "image_offer" {
  description = "Image offer"
  type        = string
  default     = "UbuntuServer"
}

# Python interpreter
variable "python_interpreter" {
  description = "Python interpreter"
  type        = string
  default     = "/usr/bin/python3"
}

# AKS
variable "aks_name" {
  description = "Azure Kubernetes Service (AKS) name"
  type        = string
  default     = "aks-cnd-cp2"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
  default     = "akscndcp2"
}

variable "node_count" {
  description = "Number of nodes in AKS cluster"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "AKS node size"
  type        = string
  default     = "Standard_B2ls_v2"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {
    casopractico2 = "true"
  }
}
