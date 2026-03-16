# Generic
resource_group_name = "rg-cnd-cp2"
location            = "Canada Central"
environment         = "dev"

# ACR
acr_name            = "acrcndcp2"

# virtual machine
vm_name             = "vm-cnd-cp2-docs"
vm_username         = "darioreyesr25"
vm_size             = "Standard_B2ls_v2"
# "Standard_B1ls" sin suficiente memoria
ssh_public_key      = "C:\\Users\\dario\\.ssh\\id_rsa.pub"
python_interpreter  = "/usr/bin/python3"

# Networking
vnet_name           = "vnet-cnd-cp2"
subnet_name         = "subnet-cnd-cp2"
subnet_cidr         = "10.0.1.0/28"

# Image
image_os            = "22_04-lts-gen2"
image_offer         = "0001-com-ubuntu-server-jammy"
# check offers here: https://documentation.ubuntu.com/azure/en/latest/azure-how-to/instances/find-ubuntu-images/

# AKS
aks_name            = "aks-cnd-cp2"
dns_prefix          = "akscndcp2"
node_count          = 1
aks_vm_size         = "Standard_B2ls_v2"

# Tags
tags = {
  environment = "casopractico2"
}