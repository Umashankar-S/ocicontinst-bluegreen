output "public_ip_lb" {
  value =  oci_load_balancer.flex_lb.ip_address_details
}

output "active_environment" {
  value       = var.active_environment
  description = "Currently active environment (blue or green)"
}

output "active_backend_set" {
  value       = var.active_environment == "blue" ? oci_load_balancer_backend_set.app1-bs-blue.name : oci_load_balancer_backend_set.app1-bs-green.name
  description = "Currently active backend set name"
}
