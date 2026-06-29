output "vnets" {
  value = azurerm_virtual_network.vnets
}

output "hub_firewall_subnet_id" {
  value = azurerm_subnet.hub_subnets["AzureFirewallSubnet"].id
}

output "subnet_ids" {
  value = {
    for vnet_name in distinct([
      for k in keys(azurerm_subnet.spoke_subnets) :
      split("-", k)[0]
    ]) :
    vnet_name => {
      for k, v in azurerm_subnet.spoke_subnets :
      v.name => v.id
      if split("-", k)[0] == vnet_name
    }
  }
}