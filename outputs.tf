output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "key_vault_name" {
  value = azurerm_key_vault.public.name
}

output "nsg_name" {
  value = azurerm_network_security_group.insecure.name
}

output "disk_name" {
  value = azurerm_managed_disk.unencrypted.name
}
