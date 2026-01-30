

terraform {
  required_providers {
      oci = {
      source = "oracle/oci"
      version = ">=7.20.0"
      configuration_aliases = [ oci ]
    }
  }

  required_version =  ">= 1.0"
}
