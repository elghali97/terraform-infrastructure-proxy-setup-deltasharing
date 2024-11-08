# ================================================================================================================
# Networking - Private Endpoints
# ================================================================================================================

// ----------- Storage Private Endpoint -----------

resource "azurerm_private_endpoint" "shared_dfs_pe" {
  name                = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-dfs-pe-${local.tags["databricks:environment"]}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared_rg.name
  subnet_id           = azurerm_subnet.shared_private_link_subnet.id

  private_service_connection{
    name                           = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-${azurerm_storage_account.adls_storage.name}-dfs-ple-${local.tags["databricks:environment"]}"
    private_connection_resource_id = azurerm_storage_account.adls_storage.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-dfs-dns-zone-${local.tags["databricks:environment"]}"
    private_dns_zone_ids = [azurerm_private_dns_zone.shared_dns_zone_dfs.id]
  }

  tags = merge(local.tags, { "databricks:name" =  "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-dbfs-dfs-pe-${local.tags["databricks:environment"]}" })
}

resource "azurerm_private_endpoint" "shared_blob_pe" {
  name                = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-blob-pe-${local.tags["databricks:environment"]}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared_rg.name
  subnet_id           = azurerm_subnet.shared_private_link_subnet.id

  private_service_connection{
    name                           = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-${azurerm_storage_account.adls_storage.name}-dfs-ple-${local.tags["databricks:environment"]}"
    private_connection_resource_id = azurerm_storage_account.adls_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-blob-dns-zone-${local.tags["databricks:environment"]}"
    private_dns_zone_ids = [azurerm_private_dns_zone.shared_dns_zone_blob.id]
  }

  tags = merge(local.tags, { "databricks:name" =  "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-blob-pe-${local.tags["databricks:environment"]}" })

}
