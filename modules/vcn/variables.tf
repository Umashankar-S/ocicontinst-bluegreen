variable "region" {
    description = "The OCI region"
    type        = string
}
#variable "tenancy_name" { }
variable  compartment_ocid {  }


#################################### Network 

################## vcn

variable "vcn_name" { default =  "bluegreen-vcn"}  
variable "label_prefix" { default =  "dev"} 
variable "vcn_cidr" { 
    type = list
   # default = ["10.100.0.0/23"] 
    }
variable "vcn_dns_label" { default = "devblugrnvcn"}
variable "enable_ipv6" { default = false }

################## subnet

variable public_lb_subnet_cidr  {  
    type = list 
   # default =  ["10.100.0.0/24"] 
     }
variable public_lb_subnet_display_name { default =  "publiclb"}  
variable public_lb_subnet_dns_label  { default =  "publiclbsn"}  


variable private_apps_subnet_cidr  { 
    type = list 
 #   default =  ["10.100.1.0/24"] 
     }
variable private_apps_subnet_display_name { default =  "privateapps"}  
variable private_apps_subnet_dns_label  { default =  "privateappssn"}  



################## DRG Attachment

# variable "drg_id" { }

