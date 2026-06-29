variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "firewall_name" {
  type = string
}

variable "firewall_pip_name" {
  type = string
}

variable "vnets" {
  type = map(object({
    address_space = list(string)
    subnets       = map(string)
    vm_name       = string
  }))
}