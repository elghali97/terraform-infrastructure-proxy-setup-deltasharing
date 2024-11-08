# ================================================================================================================
# Storage
# ================================================================================================================

resource "azurerm_storage_account" "adls_storage" {
  name                     = "dls${var.storage_account}sa${var.environment}01"
  location                 = var.location
  resource_group_name      = data.azurerm_resource_group.shared_rg.name
  
  public_network_access_enabled = true
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true

  tags = merge(local.tags, { "databricks:name" = "dls${var.storage_account}sa${var.environment}01" })

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "adls_container" {
  name                  = "deltasharing"
  storage_account_name  = azurerm_storage_account.adls_storage.name
  container_access_type = "container"
}
