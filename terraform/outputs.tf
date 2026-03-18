# Salida con la dirección IP publica de la VM
output "vm_public_ip" {
  value = module.virtual_machine.vm_public_ip
}

# Salida con la URL del ACR
output "acr_login_server" {
  value = module.container_registry.acr_login_server
}

# Salida con el nombre de usuario del ACR
output "acr_username" {
  description = "ACR Admin Username"
  value       = module.container_registry.acr_username
}

# Salida con la contraseña del ACR
output "acr_password" {
  description = "ACR Admin Password"
  value       = module.container_registry.acr_password
  sensitive   = true
}

# Salida con el nombre del grupo de recursos
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

# Salida con el nombre del AKS
output "aks_name" {
  value = module.aks.aks_name
}

# Salida con el nombre del ACR
output "acr_name" {
  value = module.container_registry.acr_name
}

# Salida con el nombre de la VM
output "vm_name" {
  value = module.virtual_machine.vm_name
}

# Salida con la ubicación
output "location" {
  value = azurerm_resource_group.rg.location
}

# Salida con el entorno
output "environment" {
  value = var.environment
}
