# ================================================================================================================
# Networking - DNS
# ================================================================================================================

// ----------- Private DNS DBFS - DFS-----------

resource "azurerm_private_dns_zone" "shared_dns_zone_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = data.azurerm_resource_group.shared_rg.name

  tags = merge(local.tags, { "databricks:name" = "privatelink.dfs.core.windows.net" })
}



resource "azurerm_private_dns_zone" "shared_dns_zone_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.shared_rg.name

  tags = merge(local.tags, { "databricks:name" = "privatelink.blob.core.windows.net" })
}


resource "azurerm_private_dns_zone_virtual_network_link" "shared_dns_dfs_link" {
  name                  = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-dbfs-dfs-con-${local.tags["databricks:environment"]}"
  resource_group_name   = data.azurerm_resource_group.shared_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.shared_dns_zone_dfs.name
  virtual_network_id    = azurerm_virtual_network.shared_vnet.id

  tags = merge(local.tags, { "databricks:name" =  "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-dbfs-dfs-con-${local.tags["databricks:environment"]}" })
}

resource "azurerm_private_dns_zone_virtual_network_link" "shared_dns_blob_link" {
  name                  = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-dbfs-blob-con-${local.tags["databricks:environment"]}"
  resource_group_name   = data.azurerm_resource_group.shared_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.shared_dns_zone_blob.name
  virtual_network_id    = azurerm_virtual_network.shared_vnet.id

  tags = merge(local.tags, { "databricks:name" =   "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-shared-dbfs-blob-con-${local.tags["databricks:environment"]}" })

}