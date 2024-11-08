# ================================================================================================================
# Networking
# ================================================================================================================

// ----------- Virtual Network -----------
resource "azurerm_virtual_network" "shared_vnet" {
  name                = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-vnet-${local.tags["databricks:environment"]}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared_rg.name
  address_space       = [var.vnet_address_cidr]

  tags = merge(local.tags, { "databricks:name" = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-vnet-${local.tags["databricks:environment"]}" })

  lifecycle {
    ignore_changes = [tags]
  }
}


// ----------- Subnet -----------
resource "azurerm_subnet" "shared_public_subnet" {
  name                 = "INTERNET"
  resource_group_name  = data.azurerm_resource_group.shared_rg.name
  virtual_network_name = azurerm_virtual_network.shared_vnet.name

  address_prefixes = [cidrsubnet(var.vnet_address_cidr, 2, 0)]
}

resource "azurerm_subnet" "shared_private_subnet" {
  name                 = "PRIVATE"
  resource_group_name  = data.azurerm_resource_group.shared_rg.name
  virtual_network_name = azurerm_virtual_network.shared_vnet.name

  address_prefixes = [cidrsubnet(var.vnet_address_cidr, 2, 1)]
}

resource "azurerm_subnet" "shared_private_link_subnet" {
  name                                      = "PRIVATELINK"
  resource_group_name                       = data.azurerm_resource_group.shared_rg.name
  virtual_network_name                      = azurerm_virtual_network.shared_vnet.name
  address_prefixes                          = [cidrsubnet(var.vnet_address_cidr, 2, 2)]
}

// ---------------- Route Table -------------------
resource "azurerm_route_table" "shared_rt" {
  name                = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-rt-${local.tags["databricks:environment"]}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared_rg.name

  tags = merge(local.tags, { "databricks:name" = " ${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-rt-${local.tags["databricks:environment"]}" })

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet_route_table_association" "private_association" {
  subnet_id      = azurerm_subnet.shared_private_subnet.id
  route_table_id = azurerm_route_table.shared_rt.id
}

resource "azurerm_subnet_route_table_association" "public_association" {
  subnet_id      = azurerm_subnet.shared_public_subnet.id
  route_table_id = azurerm_route_table.shared_rt.id
}
