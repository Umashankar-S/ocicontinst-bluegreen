output "private_apps_subnet_ocid" {
  value =  "${oci_core_subnet.private_apps_subnet.id}"
}
output "public_lb_subnet_ocid" {
  value =  "${oci_core_subnet.public_lb_subnet.id}"
}

output "lb_nsg_id" {
  value =  "${oci_core_network_security_group.loadbalancer_network_security_group.id}"
}

output "coninst_nsg_id" {
  value =  "${oci_core_network_security_group.coninst_network_security_group.id}"
}
