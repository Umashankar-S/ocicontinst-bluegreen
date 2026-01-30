provider "oci" {
  ### These information are needed only outside of OCI Terraform Stack Manager
  #tenancy_ocid     = var.tenancy_ocid
  #user_ocid        = var.user_ocid
  #fingerprint      = var.fingerprint
  #private_key_path = var.private_key_path
  region           = var.region
  alias = "current_region"
}

provider "oci" {
  alias  = "home"
  #region = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  region = var.home_region
  # user_ocid        = var.user_ocid
  # tenancy_ocid     = var.tenancy_id
  # private_key      = var.private_key
  # fingerprint      = var.fingerprint
}

terraform {
  required_providers {
      oci = {
      source = "oracle/oci"
      version = ">=7.20.0"
      configuration_aliases = [ oci.home ,oci.current_region ]
    }
  }
  required_version =  ">= 1.0"
}
