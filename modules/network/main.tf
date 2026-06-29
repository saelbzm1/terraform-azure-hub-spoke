
resource "azurerm_virtual_network" "vnets" {
  for_each            = var.vnets
  name                = "vnet-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = each.value.address_space
}

# HUB subnets (imposés Azure)
resource "azurerm_subnet" "hub_subnets" {
  for_each = {
    AzureFirewallSubnet = "10.0.1.0/24"
    AzureBastionSubnet  = "10.0.2.0/24"
    GatewaySubnet       = "10.0.3.0/24"
  }

  name                 = each.key
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnets["hub"].name
  address_prefixes     = [each.value]
}

resource "azurerm_subnet" "spoke_subnets" {
  for_each = merge([
    for vnet_key, vnet in var.vnets : {
      for subnet_key, subnet_value in vnet.subnets :
      "${vnet_key}-${subnet_key}" => {
        vnet = vnet_key
        name = subnet_key
        cidr = subnet_value
      }
    }
  ]...)

  name                 = each.value.name
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnets[each.value.vnet].name
  address_prefixes     = [each.value.cidr]
}