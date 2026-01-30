########################  OCI Provider  Module Variables ########################

variable "region" {
    description = "The OCI region"
    type        = string
}

variable "home_region" {
    description = "The OCI Home region"
    type        = string
}

variable "compartment_ocid" {
    description = "The OCI Compartment ocid"
    type        = string
}


######################## Conatiner Instance Module Variables ########################

variable "ci_name" {
    description = "The OCI Container Instance Name"
    type        = string
    default     = "ContainerInst"
}

variable "ci_restart_policy" {
    description = "The OCI Container Instance Retsrat Policy"
    type        = string
    default     = "ALWAYS"
}

variable "ci_state" {
    description = "The OCI Container Instance State"
    type        = string
    default     = "ACTIVE"
}

variable "ci_shape" {
    description = "The OCI Container Instance Shape"
    type        = string
    default     = "CI.Standard.E4.Flex"
}

variable "ci_ocpus" {
    description = "The OCI Container Instance Ocpu Number"
    type        = number
    default     = 1
}

variable "ci_memory" {
    description = "The OCI Container Instance Memory GB Number"
    type        = number
    default     = 4
}

variable "ci_1_container_name_blue" {
    description = "The OCI Container Name"
    type        = string
    default     = "CI_CONTAINER_"
}

variable "ci_1_image_url_blue" {
    description = "The OCI Container Image Url"
    type        = string
}

variable "ci_2_container_name_blue" {
    description = "The OCI Container Name"
    type        = string
    default     = "CI_CONTAINER_"
}

variable "ci_2_image_url_blue" {
    description = "The OCI Container Image Url"
    type        = string
}

variable "ci_1_container_name_green" {
    description = "The OCI Container Name"
    type        = string
    default     = "CI_CONTAINER_"
}

variable "ci_1_image_url_green" {
    description = "The OCI Container Image Url"
    type        = string
}

variable "ci_2_container_name_green" {
    description = "The OCI Container Name"
    type        = string
    default     = "CI_CONTAINER_"
}

variable "ci_2_image_url_green" {
    description = "The OCI Container Image Url"
    type        = string
}


variable "green_ci_prefix" {
    description = "Green CI Prefix"
    type        = string
    default = "green"
}
variable "blue_ci_prefix" {
    description = "Blue CI prefix"
    type        = string
    default = "blue"
}


variable "ci_count_blue" {
    description = "The OCI Container Instance Count Number"
    type        = number
}
variable "ci_count_green" {
    description = "The OCI Container Instance Count Number"
    type        = number
}

variable "is_public_ip_assigned" {
    description = "Does the CI has a public ip ?"
    type        = bool
    default     = false
}


######################## Loadbalancer Module Variables ########################

variable "load_balancer_shape_details_maximum_bandwidth_in_mbps" {
    description = "The OCI LB Max Bandwith"  
    type        = number
    default = 40
}

variable "load_balancer_shape_details_minimum_bandwidth_in_mbps" {
    description = "The OCI LB Max Bandwith"  
    type = number
    default = 10
}


variable "lb_name" {
    description = "The OCI LB Name"
    type        = string
    default     = "CI_FLEX_LB"
}


variable "lb_checker_health_port_app1" {
    description = "The OCI LB Health Checker Port"
    type        = string
    default     = "8002"
}


variable "lb_checker_health_port_app2" {
    description = "The OCI LB Health Checker Port"
    type        = string
    default     = "80"
}


variable "lb_checker_url_path" {
    description = "The OCI LB Health Checker URL"
    type        = string
    default     = "/"
}

variable "lb_listener_port_blue" {
    description = "The OCI LB Listener Port"
    type        = number
    default     = 8000
}
variable "lb_listener_port_green" {
    description = "The OCI LB Listener Port"
    type        = number
    default     = 8005
}
variable "lb_listener_port_active" {
    description = "The OCI LB Listener Port"
    type        = number
    default     = 8010
}


variable "lb_backend_port_app1" {
    description = "The OCI LB Backend Port"
    type        = number
    default     = 8002
}

variable "lb_backend_port_app2" {
    description = "The OCI LB Backend Port"
    type        = number
    default     = 80
}


########################## Blue green  Active environment ########################


variable "active_environment" {
  description = "Active environment: 'blue' or 'green'"
  type        = string
#   default     = "blue"
  
  validation {
    condition     = contains(["blue", "green"], var.active_environment)
    error_message = "Active environment must be either 'blue' or 'green'."
  }
}




 
########################## Network Module Variables ##########################

#### VCN

variable "vcn_name" { default =  "bluegreen-vcn"}  
variable "label_prefix" { default =  "np"} 
variable "vcn_cidr" { 
    type = list
    default = ["10.200.0.0/23"] 
    }
variable "vcn_dns_label" { default = "bluegreencnnp"}
variable "enable_ipv6" { default = false }

#### Subnet

variable public_lb_subnet_cidr  {  
    type = list 
    default =  ["10.200.0.0/24"] 
     }
variable public_lb_subnet_display_name { default =  "publiclb"}  
variable public_lb_subnet_dns_label  { default =  "publiclbsn"}  


variable private_apps_subnet_cidr  { 
    type = list 
    default =  ["10.200.1.0/24"] 
     }
variable private_apps_subnet_display_name { default =  "privateapps"}  
variable private_apps_subnet_dns_label  { default =  "privateappssn"}  

