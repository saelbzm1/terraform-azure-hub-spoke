output "vm_ids" {
  value = {
    for k, vm in module.vm :
    k => vm.vm_id
  }
}