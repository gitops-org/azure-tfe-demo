import "tfplan"

get_vms = func() {
    vms = []
    for tfplan.module_paths as path {
        vms += values(tfplan.module(path).resources.azurerm_virtual_machine) else []
    }
    return vms
}

# comparison is case-sensitive
# so including both cases for "v"
# since we have seen both used
allowed_vm_sizes = [
    "Standard_DS1_v2",
]

vms = get_vms()
vm_size_allowed = rule {
    all vms as _, instances {
      all instances as index, r {
  	   r.applied.vm_size in allowed_vm_sizes
      }
    }
}

main = rule {
  (vm_size_allowed) else true
}
