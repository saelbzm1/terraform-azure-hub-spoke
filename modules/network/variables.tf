variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnets" {
  type = map(object({
    address_space = list(string)
    subnets       = map(string)
    vm_name       = string
  }))
}
