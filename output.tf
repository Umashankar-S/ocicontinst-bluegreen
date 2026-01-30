
output "public_ip_lb" {
  value = module.loadbalancer.public_ip_lb
}
output "active_environment" {
  value       = var.active_environment
  description = "Currently active environment (blue or green)"
}

output "private_ips_blue" {
  value =  module.containerinstance-blue.private_ips
  description = "Private Ips assigned to Blue Conatiner Instances"

}

output "private_ips_green" {
  value =  module.containerinstance-green.private_ips
  description = "Private Ips assigned to Green Conatiner Instances"

}