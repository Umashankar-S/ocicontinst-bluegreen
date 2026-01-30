variable "compartment_ocid" {
    description = "The OCI Compartment ocid"
    type        = string
}
variable "region" {
    description = "The OCI region"
    type        = string
}

variable "ci_subnet_id" {
    description = "The OCI Private Subnet ocid for CI "
    type        = string
}

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

# variable "ci_container_name" {
#     description = "The OCI Container Name"
#     type        = string
#     default     = "CI_CONTAINER_"
# }

# variable "ci_image_url" {
#     description = "The OCI Container Image Url"
#     type        = string
# }

variable "ci_1_container_name" {
    description = "The OCI Container Name"
    type        = string
    default     = "CI_CONTAINER_"
}

variable "ci_1_image_url" {
    description = "The OCI Container Image Url"
    type        = string
}

variable "ci_2_container_name" {
    description = "The OCI Container Name"
    type        = string
    default     = "CI_CONTAINER_"
}

variable "ci_2_image_url" {
    description = "The OCI Container Image Url"
    type        = string
}
variable "ci_count" {
    description = "The OCI Container Instance Count Number"
    type        = number
}

variable "ci_prefix" {
    description = "The OCI Container Instance Prefix"
    type        = string
    default = ""
}

# variable "ci_registry_vault_secret_id" {
#     description = "The OCI Vault Secret Id with username and password of OCI registry"
#     type        = string
# }

variable "is_public_ip_assigned" {
    description = "Does the CI has a public ip ?"
    type        = bool
    default = false
}


variable "coninst_nsg_id" {
    description = "NSG ID for Conatiner Instance"
    type        = string
}

