### Conatiner Instance Module 
### This Module deployes #ci_count of instances in the private Subnet
### 2 Conatiners are hosted  in each Conatiner Instance ,  
### Conatiner # 1 (App1) runs on port 8002 and Conatiner # 2 (App2) runs on port 80


resource "oci_container_instances_container_instance" "this" {
  count = var.ci_count
  compartment_id           = var.compartment_ocid
  display_name             = "${var.ci_name}_${count.index}"
  availability_domain      = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  container_restart_policy = var.ci_restart_policy
  state                    = var.ci_state
  shape                    = var.ci_shape
  shape_config {
    ocpus         = var.ci_ocpus
    memory_in_gbs = var.ci_memory
  }
  vnics {
    display_name           = "${var.ci_prefix}vnicinst${count.index}"
    hostname_label         = "${var.ci_prefix}coninst${count.index}"
    subnet_id              = var.ci_subnet_id
    skip_source_dest_check = false
    is_public_ip_assigned  = var.is_public_ip_assigned
    nsg_ids = [ var.coninst_nsg_id ]
  }
  containers {
    display_name          = "${var.ci_1_container_name}${count.index}"
    image_url             = var.ci_1_image_url
  }
  containers {
    display_name          = "${var.ci_2_container_name}${count.index}"
    image_url             = var.ci_2_image_url
  }

   lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}