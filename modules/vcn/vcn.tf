### Network Module to Create VCN with 1 Private Subnet & 1 Public Subnet
### Conatiner Instance will be hosted on Private Subnet
### Loadbalancer will be hosted on Public Subnet


### Sleep to allow OCI network compoennets delay before using in further modules
### Added based on few glitces due to OCI network componenet creations delay

resource "time_sleep" "wait_for_sgw" {
  create_duration = "30s"  # Wait 30s seconds
  depends_on = [
    oci_core_service_gateway.vcn_srvc_gtwy
  ]
}


################## VCN 

resource "oci_core_vcn" "vcn" {
   
    cidr_blocks    = [var.vcn_cidr[0]]
    compartment_id = var.compartment_ocid
    display_name   = var.label_prefix == "none" ? var.vcn_name : "${var.label_prefix}-${var.vcn_name}"
    dns_label      = var.vcn_dns_label
    is_ipv6enabled = var.enable_ipv6
  
    #freeform_tags = var.freeform_tags
    #defined_tags  = var.defined_tags
  
    lifecycle {
      ignore_changes = [defined_tags, dns_label, freeform_tags]
    }
  }


################## Subnets  -  1. public_lb_subnet
  resource oci_core_subnet public_lb_subnet {
    cidr_block     =  var.public_lb_subnet_cidr[0]
    compartment_id = var.compartment_ocid
    
    dhcp_options_id = oci_core_vcn.vcn.default_dhcp_options_id
    display_name    = var.public_lb_subnet_display_name
    dns_label       = var.public_lb_subnet_dns_label
    freeform_tags = {
    }
    ipv6cidr_blocks = [
    ]
    prohibit_internet_ingress  = "false"
    prohibit_public_ip_on_vnic = "false"
    route_table_id             = oci_core_route_table.public_lb_subnet_route_table.id
    security_list_ids = [
      oci_core_security_list.public_lb_subnet-Security-List.id,
    ]
    vcn_id = oci_core_vcn.vcn.id
    lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
      depends_on = [ time_sleep.wait_for_sgw ]
  }
  
 ################## Subnets  -  2. private_apps_subnet
  resource oci_core_subnet private_apps_subnet {
    cidr_block     =  var.private_apps_subnet_cidr[0]
    compartment_id = var.compartment_ocid
    
    dhcp_options_id = oci_core_vcn.vcn.default_dhcp_options_id
    display_name    = var.private_apps_subnet_display_name
    dns_label       = var.private_apps_subnet_dns_label
    freeform_tags = {
    }
    ipv6cidr_blocks = [
    ]
    prohibit_internet_ingress  = "true"
    prohibit_public_ip_on_vnic = "true"
    route_table_id             = oci_core_route_table.private_apps_subnet_route_table.id
    security_list_ids = [
      oci_core_security_list.private_apps_subnet-Security-List.id,
    ]
    vcn_id = oci_core_vcn.vcn.id
    lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
   depends_on = [ time_sleep.wait_for_sgw ]
  } 

##################  Gateways 

###  Service Gateway (SGW)
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "vcn_srvc_gtwy" {
  compartment_id = var.compartment_ocid
  display_name   = "srvc_gateway"

  services {
    service_id = lookup(data.oci_core_services.all_oci_services.services[0], "id")
  }

  vcn_id = oci_core_vcn.vcn.id

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

###  NAT Gateway


resource oci_core_nat_gateway vcn_nat_gtway {
  block_traffic  = "false"
  compartment_id = var.compartment_ocid
  display_name = "nat-gateway"
  freeform_tags = {
   
  }
  vcn_id = oci_core_vcn.vcn.id
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }

}

###  Internet Gateway

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_ocid
  display_name   = "internet-gateway"

  vcn_id = oci_core_vcn.vcn.id

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }

 # count = var.create_internet_gateway == true ? 1 : 0
 
}


################## Route tables 


resource "oci_core_route_table" "public_lb_subnet_route_table" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id

    #Optional
    display_name = "${var.public_lb_subnet_display_name}_rt"
    # route_rules {
    #     #Required
    #     network_entity_id = oci_core_service_gateway.vcn_srvc_gtwy.id

    #     #Optional
    #     destination       = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")
    #     destination_type  = "SERVICE_CIDR_BLOCK"
    #     description       = "Terraformed - Auto-generated at Service Gateway creation: All Services in region to Service Gateway"
    # }
     route_rules {
        #Required
        network_entity_id = oci_core_internet_gateway.ig.id

        #Optional
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        description       = "Route extrnal IPs to DRG "
  }
 
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_route_table" "private_apps_subnet_route_table" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id

    #Optional
    display_name = "${var.private_apps_subnet_display_name}_rt"
    route_rules {
        #Required
        network_entity_id = oci_core_nat_gateway.vcn_nat_gtway.id

        #Optional
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        description       = "NAT route for downloads of public images/ocir cred provider"
    }
    route_rules {
        #Required
        network_entity_id = oci_core_service_gateway.vcn_srvc_gtwy.id

        #Optional
        destination       = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")
        destination_type  = "SERVICE_CIDR_BLOCK"
        description       = "Terraformed - Auto-generated at Service Gateway creation: All Services in region to Service Gateway"
    }
    
   lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
    
}





################## Secuirty Lists 


resource "oci_core_security_list" "public_lb_subnet-Security-List" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.vcn.id


  display_name = "${var.public_lb_subnet_display_name}_sl"
  egress_security_rules {
    description = "Egress all within VCN"
    destination      = var.vcn_cidr[0]
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
   
  }
  freeform_tags = {
  }
  # ingress_security_rules {
  #   protocol    = "6"
  #   source      = "0.0.0.0/0"
  #   source_type = "CIDR_BLOCK"
  #   stateless   = "false"
  #   tcp_options {
  #     max = "22"
  #     min = "22"
  #     #source_port_range = <<Optional value >>
  #   }
  #   #udp_options = <<Optional value >>
  # }
  ingress_security_rules {
    
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    #description = <<Optional value >>
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = var.vcn_cidr[0]
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    #tcp_options = <<Optional value >>
    #udp_options = <<Optional value >>
  }
  ingress_security_rules {
   
    protocol    = "6"
    source      = var.vcn_cidr[0]
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "80"
      min = "80"
    }
  }
#    manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id
   
}

resource "oci_core_security_list" "private_apps_subnet-Security-List" {
  compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id


  display_name = "${var.private_apps_subnet_display_name}_sl"
  egress_security_rules {
    description = "Egress all within VCN"
    destination      = var.vcn_cidr[0]
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
   
  }
   egress_security_rules {
    description = "Egress to OCI Services"
    destination      = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol    = "all"
    stateless = "false"
    # tcp_options {
    #   max = "443"
    #   min = "443"
    # }
   
  }
  freeform_tags = {
  }
  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_cidr[0]
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "8100"
      min = "80"
      #source_port_range = <<Optional value >>
    }
    #udp_options = <<Optional value >>
  }
  ingress_security_rules {
    
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    #description = <<Optional value >>
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = var.vcn_cidr[0]
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    #tcp_options = <<Optional value >>
    #udp_options = <<Optional value >>
  }
 #   manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id
   
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
  depends_on = [ oci_core_service_gateway.vcn_srvc_gtwy ]

}


resource "oci_core_network_security_group" "loadbalancer_network_security_group" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id

    #Optional
    display_name = "loadbalancer_nsg"
    lifecycle {
    create_before_destroy = false
  }
}

resource "oci_core_network_security_group_security_rule" "lb_ingress_rule" {
    #Required
    network_security_group_id = oci_core_network_security_group.loadbalancer_network_security_group.id
    direction = "INGRESS"
    protocol = "6"

    #Optional
    description = "Ingress rule for LB "
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    #stateless = false
    tcp_options {

        #Optional
        destination_port_range {
            #Required
            max = "8100"
            min = "8000"
        }
       
    }
   
}

resource "oci_core_network_security_group_security_rule" "lb_egress_rule" {
    #Required
    network_security_group_id = oci_core_network_security_group.loadbalancer_network_security_group.id
    direction = "EGRESS"
    protocol = "6"

    #Optional
    description = "Egress to Conatiner Instances"
    destination = var.private_apps_subnet_cidr[0]
    destination_type = "CIDR_BLOCK"
    #stateless = false
    tcp_options {

        #Optional
        destination_port_range {
            #Required
            max = "8100"
            min = "80"
        }
       
    }
   
}


resource "oci_core_network_security_group" "coninst_network_security_group" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id

    #Optional
    display_name = "coninst_nsg"
   lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
    depends_on = [ oci_core_service_gateway.vcn_srvc_gtwy ]
}

resource "oci_core_network_security_group_security_rule" "coninst_ingress_rule" {
    #Required
    network_security_group_id = oci_core_network_security_group.coninst_network_security_group.id
    direction = "INGRESS"
    protocol = "6"

    #Optional
    description = "Ingress rule for LB "
    source = var.public_lb_subnet_cidr[0]
    source_type = "CIDR_BLOCK"
    #stateless = false
    tcp_options {

        #Optional
        destination_port_range {
            #Required
            max = "8100"
            min = "80"
        }
       
    }
   
}

resource "oci_core_network_security_group_security_rule" "coninst_egress_rule" {
    #Required
    network_security_group_id = oci_core_network_security_group.coninst_network_security_group.id
    direction = "EGRESS"
    protocol = "6"

    #Optional
    description = "Egress to Conatiner Instances"
    destination = var.private_apps_subnet_cidr[0]
    destination_type = "CIDR_BLOCK"
    #stateless = false
    tcp_options {

        #Optional
        destination_port_range {
            #Required
            max = "8100"
            min = "80"
        }
       
    }
   
}
resource "oci_core_network_security_group_security_rule" "coninst_egress_rule_2" {
    #Required
    network_security_group_id = oci_core_network_security_group.coninst_network_security_group.id
    direction = "EGRESS"
    protocol = "all"

    #Optional
    description = "Egress to services for Image pull"
    #destination =  "0.0.0.0/0"
    destination = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
   
}

# ########## DRG Attachements

# # resource oci_core_drg_attachment drgattachment {
  
# #   display_name       = "drgattachment-${var.vcn_name}"
# #   drg_id             = var.drg_id
# #   freeform_tags = {
# #   }
# #   vcn_id = oci_core_vcn.vcn.id
# # }
