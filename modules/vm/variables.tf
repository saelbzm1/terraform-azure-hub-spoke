variable "name" {}
variable "location" {}
variable "rg_name" {}
variable "subnet_id" {}
variable "admin_username" {}
variable "admin_password" {
  sensitive = true
}
