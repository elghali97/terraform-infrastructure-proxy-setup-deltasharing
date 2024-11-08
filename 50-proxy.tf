# ================================================================================================================
# Instances : Delta Sharing VM
# ================================================================================================================

// ----------- Network Security Group -----------
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-nsg-${local.tags["databricks:environment"]}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared_rg.name

  security_rule {
    name                       = "AllowHTTPSAccess"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = var.ingress_ips
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowHTTPAccess"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = var.ingress_ips
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowSSHAccess"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = var.ingress_ips
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowCustomHTTPAccess"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 8080
    source_address_prefix      = var.ingress_ips
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowCustomHTTPAccessFromAWS"
    priority                   = 600
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 8888
    source_address_prefix      = "52.212.90.230/32"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowOutboundAccess"
    priority                   = 400
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = merge(local.tags, { "databricks:name" = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-vm-nsg-${local.tags["databricks:environment"]}" })

  lifecycle {
    ignore_changes = [tags]
  }
}

// ----------- Network Interface -----------
resource "azurerm_public_ip" "delta_sharing_vm_public_ip" {
  name                = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-dsharevm-pip-${local.tags["databricks:environment"]}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared_rg.name
  domain_name_label   = "dshare-databricks-test"

  allocation_method = "Static"
  sku               = "Standard"

  tags = merge(local.tags, { "databricks:name" = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-dsharevm-pip-${local.tags["databricks:environment"]}" })
}

resource "azurerm_network_interface" "delta_sharing_vm_nic" {
  name                = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-dsharevm-nic-${local.tags["databricks:environment"]}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared_rg.name

  ip_configuration {
    name                          = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-dsharevm-ipconf-${local.tags["databricks:environment"]}"
    subnet_id                     = azurerm_subnet.shared_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.delta_sharing_vm_public_ip.id
  }

  tags = merge(local.tags, { "databricks:name" = "${local.tags["databricks:region"]}-${local.tags["databricks:project"]}-dsharevm-nic-${local.tags["databricks:environment"]}" })

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_interface_security_group_association" "delta_sharing_vm_association" {
  network_interface_id      = azurerm_network_interface.delta_sharing_vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

// ----------- Virtual Machine -----------

resource "azurerm_linux_virtual_machine" "delta_sharing_instance" {
  name                = "${local.tags["databricks:region"]}${local.tags["databricks:project"]}dsharevm${local.tags["databricks:environment"]}"
  resource_group_name = data.azurerm_resource_group.shared_rg.name
  location            = var.location

  size           = "Standard_F2"
  admin_username = "adminuser"
  admin_password = "@dminPASS123"

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.delta_sharing_vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  user_data = base64encode(
    templatefile(
      "./scripts/install-tiny-proxy.tpl",
      {}
    )
  )

  tags = merge(local.tags, { "databricks:name" =  "${local.tags["databricks:region"]}${local.tags["databricks:project"]}dsharevm${local.tags["databricks:environment"]}" })

  lifecycle {
    ignore_changes = [tags]
  }
}



