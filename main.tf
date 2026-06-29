resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source              = "./modules/network"
  location            = var.location
  resource_group_name = var.resource_group_name
  vnets               = var.vnets
}

module "firewall" {
  source              = "./modules/firewall"
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_name       = var.firewall_name
  pip_name            = var.firewall_pip_name
  firewall_subnet_id  = module.network.hub_firewall_subnet_id
}

# -------------------
# VMs dynamiques
# -------------------
module "vm" {
  for_each = {
    for k, v in var.vnets :
    k => v if k != "hub"
  }

  source          = "./modules/vm"
  name            = each.value.vm_name
  location        = var.location
  rg_name         = var.resource_group_name
  subnet_id       = module.network.subnet_ids[each.key][keys(each.value.subnets)[0]]
  admin_username  = var.admin_username
  admin_password  = var.admin_password
}

# -------------------
# VNET PEERING DYNAMIQUE
# -------------------
resource "azurerm_virtual_network_peering" "hub_to_spokes" {
  for_each = {
    for k, v in module.network.vnets :
    k => v if k != "hub"
  }

  name                      = "hub-to-${each.key}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = module.network.vnets["hub"].name
  remote_virtual_network_id = each.value.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spokes_to_hub" {
  for_each = {
    for k, v in module.network.vnets :
    k => v if k != "hub"
  }

  name                      = "${each.key}-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = each.value.name
  remote_virtual_network_id = module.network.vnets["hub"].id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# -------------------
# ROUTE TABLES (100% dynamique)
# -------------------
resource "azurerm_route_table" "spoke_rt" {
  for_each = merge([
    for k, v in module.network.subnet_ids : {
      for subnet_name, subnet_id in v :
      "${k}-${subnet_name}" => {
        vnet      = k
        subnet    = subnet_name
        subnet_id = subnet_id
      }
      if k != "hub"
    }
  ]...)

  name                = "rt-${each.value.vnet}-${each.value.subnet}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_route" "default_route" {
  for_each = azurerm_route_table.spoke_rt

  name                   = "default-to-fw"
  resource_group_name    = var.resource_group_name
  route_table_name       = each.value.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.firewall.firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "assoc" {
  for_each = merge([
    for k, v in module.network.subnet_ids : {
      for subnet_name, subnet_id in v :
      "${k}-${subnet_name}" => {
        subnet_id = subnet_id
        rt_id     = azurerm_route_table.spoke_rt["${k}-${subnet_name}"].id
      }
      if k != "hub"
    }
  ]...)

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.rt_id
}

resource "azurerm_network_security_group" "nsg" {
  for_each = {
    for vnet_name, vnet in var.vnets :
    vnet_name => vnet if vnet_name != "hub"
  }

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
resource "azurerm_network_security_rule" "web_inbound" {
  name                        = "allow-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  destination_port_range      = "80"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg["web"].name
}
resource "azurerm_network_security_rule" "app_inbound" {
  name                        = "allow-from-web"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "10.1.0.0/16"
  destination_port_range      = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg["app"].name
}
resource "azurerm_network_security_rule" "db_inbound" {
  name                        = "allow-from-app"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "10.2.0.0/16"
  destination_port_range      = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg["db"].name
}
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = {
    for vnet_name, subnets in module.network.subnet_ids :
    vnet_name => subnets if vnet_name != "hub"
  }

  subnet_id = module.network.subnet_ids[each.key][keys(each.value)[0]]

  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}