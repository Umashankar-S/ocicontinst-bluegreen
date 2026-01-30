### This Repo deploys Conatiner instances with blue-green deployment approach
### Network and Loadbalancer is also created along with this module




### Sleep 60s to allow Network creation complete and successful Conatiner Instance creation
resource "time_sleep" "wait_for_network" {
  create_duration = "60s"  # Wait 60s seconds
  depends_on = [
    module.vcn
  ]
}

### Network Module to Create VCN with 1 Private Subnet & 1 Public Subnet
### Conatiner Instance will be hosted on Private Subnet
### Loadbalancer will be hosted on Public Subnet

module "vcn" {
  source  = "./modules/vcn"
  region=var.region
  compartment_ocid  = var.compartment_ocid
  vcn_name          = var.vcn_name
  vcn_cidr          = var.vcn_cidr
  vcn_dns_label     =  var.vcn_dns_label
  label_prefix      = var.label_prefix
  public_lb_subnet_cidr = var.public_lb_subnet_cidr
  private_apps_subnet_cidr = var.private_apps_subnet_cidr

   providers = {
    oci      = oci
    # oci.home = oci.home
  }

}

### Conatiner Instance Module - Blue
### This Module deployes #ci_count_blue of instances in the private Subnet
### 2 Conatiners are hosted  in each Conatiner Instance ,  
### Conatiner # 1 (App1) runs on port 8002 and Conatiner # 2 (App2) runs on port 80

module "containerinstance-blue" {
  source  = "./modules/containerinstance"
  region=var.region
  compartment_ocid  = var.compartment_ocid
#  private_subnet_ocid = var.private_subnet_ocid
  ci_prefix = var.blue_ci_prefix
  ci_name = "${var.blue_ci_prefix}_${var.ci_name}"
  ci_restart_policy = var.ci_restart_policy
  ci_subnet_id = module.vcn.private_apps_subnet_ocid
  ci_state = var.ci_state
  ci_shape = var.ci_shape
  ci_ocpus = var.ci_ocpus
  ci_memory = var.ci_memory
  ci_1_container_name = var.ci_1_container_name_blue
  ci_1_image_url = var.ci_1_image_url_blue
  ci_2_container_name = var.ci_2_container_name_blue
  ci_2_image_url = var.ci_2_image_url_blue
  #ci_registry_vault_secret_id =  module.kms_vault.ci_registry_vault_secret_id
  ci_count = var.ci_count_blue
  is_public_ip_assigned = var.is_public_ip_assigned
  coninst_nsg_id = module.vcn.coninst_nsg_id

   providers = {
    oci      = oci
    # oci.home = oci.home
  }
  #depends_on = [module.vcn]
  depends_on = [   time_sleep.wait_for_network  ]
 }



### Conatiner Instance Module - Green
### This Module deployes #ci_count_green of instances in the private Subnet
### 2 Conatiners are hosted  in each Conatiner Instance ,  
### Conatiner # 1 (App1) runs on port 8002 and Conatiner # 2 (App2) runs on port 80

module "containerinstance-green" {
  source  = "./modules/containerinstance"
  region=var.region
  compartment_ocid  = var.compartment_ocid
#  private_subnet_ocid = var.private_subnet_ocid
  ci_prefix = var.green_ci_prefix
  ci_name = "${var.green_ci_prefix}_${var.ci_name}"
  ci_restart_policy = var.ci_restart_policy
  ci_subnet_id = module.vcn.private_apps_subnet_ocid
  ci_state = var.ci_state
  ci_shape = var.ci_shape
  ci_ocpus = var.ci_ocpus
  ci_memory = var.ci_memory
  ci_1_container_name = var.ci_1_container_name_green
  ci_1_image_url = var.ci_1_image_url_green
  ci_2_container_name = var.ci_2_container_name_green
  ci_2_image_url = var.ci_2_image_url_green
  #ci_registry_vault_secret_id =  module.kms_vault.ci_registry_vault_secret_id
  ci_count = var.ci_count_green
  is_public_ip_assigned = var.is_public_ip_assigned
  coninst_nsg_id = module.vcn.coninst_nsg_id

   providers = {
    oci      = oci
    # oci.home = oci.home
  }
  depends_on = [   time_sleep.wait_for_network ]
 }


###  Loadbalancer Module
###  Flexible Loadbalancer gets deployed on Public Subnet 
###  It hosts 3 Listener ,  1. Blue Listener , 2. Green Listener ,3.Active Listener
###  There are 4 Backend set created  : Blue App1 - Backend Set , Blue  App2 - Backendset , 
###  Green App1 Backend Set , Green App2 Backend set
###  Blue Listener caters to Blue App1 - Backend Set , Blue  App2 - Backendset
###  Green Listener caters to Green App1 - Backend Set , Green  App2 - Backendset
###  Active Listener caters to either Blue or Green Backend sets based on ORM stack variable active_environment




module "loadbalancer" {
  source  = "./modules/loadbalancer"
  region=var.region
  compartment_ocid  = var.compartment_ocid
  public_subnet_ocid = module.vcn.public_lb_subnet_ocid
  load_balancer_shape_details_minimum_bandwidth_in_mbps = var.load_balancer_shape_details_minimum_bandwidth_in_mbps
  load_balancer_shape_details_maximum_bandwidth_in_mbps = var.load_balancer_shape_details_maximum_bandwidth_in_mbps
  private_ips_blue = module.containerinstance-blue.private_ips
  private_ips_green = module.containerinstance-green.private_ips

  lb_nsg_id = module.vcn.lb_nsg_id
  lb_name = var.lb_name

  active_environment = var.active_environment
  lb_checker_health_port_app1 = var.lb_checker_health_port_app1
  lb_checker_health_port_app2 = var.lb_checker_health_port_app2
  lb_checker_url_path = var.lb_checker_url_path
  lb_backend_port_app1 = var.lb_backend_port_app1
  lb_backend_port_app2 = var.lb_backend_port_app2

  lb_listener_port_blue = var.lb_listener_port_blue
  lb_listener_port_green = var.lb_listener_port_green
  lb_listener_port_active = var.lb_listener_port_active
  
   providers = {
    oci      = oci
    # oci.home = oci.home
  }
}