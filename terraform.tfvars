location            = "France Central"
resource_group_name = "rg-final"

admin_username      = "azureuser"
admin_password      = "P@ssw0rd1234!"

firewall_name       = "firewall-hub"
firewall_pip_name   = "pip-firewall"

vnets = {
  hub = {
    address_space = ["10.0.0.0/16"]
    subnets       = {}
    vm_name       = ""
  }

  web = {
    address_space = ["10.1.0.0/16"]
    subnets = {
      subnet-web = "10.1.1.0/24"
    }
    vm_name = "vm-web"
  }

  app = {
    address_space = ["10.2.0.0/16"]
    subnets = {
      subnet-app = "10.2.1.0/24"
    }
    vm_name = "vm-app"
  }

  db = {
    address_space = ["10.3.0.0/16"]
    subnets = {
      subnet-db = "10.3.1.0/24"
    }
    vm_name = "vm-db"
  }
}