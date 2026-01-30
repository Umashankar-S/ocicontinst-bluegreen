variable "compartment_ocid" {
    description = "The OCI Compartment ocid"
    type        = string
}

variable "region" {
    description = "The OCI region"
    type        = string
}
variable "public_subnet_ocid" {
    description = "The OCI Public Subnet ocid"
    type        = string
}

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

variable "private_ips_blue" {
    description = "The OCI List of Container Instance Private IP Address - Blue"
    type        = list
}

variable "private_ips_green" {
    description = "The OCI List of Container Instance Private IP Address - Green"
    type        = list
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
variable "lb_nsg_id" {
    description = "Loadbalancer NSG ID"
    type        = string
}


## Blue green  Active env



variable "active_environment" {
  description = "Active environment: 'blue' or 'green'"
  type        = string
 # default     = "blue"
  
  validation {
    condition     = contains(["blue", "green"], var.active_environment)
    error_message = "Active environment must be either 'blue' or 'green'."
  }
}