import "tfplan"

get_sgs = func() {
    sgs = []
    for tfplan.module_paths as path {
        sgs += values(tfplan.module(path).resources.azurerm_network_security_group) else []
    }
    return sgs
}

network_sgs = get_sgs()

disallowed_cidr_blocks = ["0.0.0.0/0"]

block_allow_all = rule {
  all network_sgs as _, instances {
    all instances as _, sg {
    	all sg.applied.security_rule as _, sr {
        	(sr.source_address_prefix not in disallowed_cidr_blocks) or sr.access == "Deny"
    	}
    }
  }
}

main = rule {
  (block_allow_all) else true
 }
