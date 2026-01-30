###  Loadbalancer Module
###  Flexible Loadbalancer gets deployed on Public Subnet 
###  It hosts 3 Listener ,  1. Blue Listener , 2. Green Listener ,3.Active Listener
###  There are 4 Backend set created  : Blue App1 - Backend Set , Blue  App2 - Backendset , 
###  Green App1 Backend Set , Green App2 Backend set
###  Blue Listener caters to Blue App1 - Backend Set , Blue  App2 - Backendset
###  Green Listener caters to Green App1 - Backend Set , Green  App2 - Backendset
###  Active Listener caters to either Blue or Green Backend sets based on ORM stack variable active_environment


resource "oci_load_balancer" "flex_lb" {
  shape          = "flexible"
  compartment_id = var.compartment_ocid
  is_private = false

  subnet_ids = [
    var.public_subnet_ocid
  ]

  shape_details {
    #Required
    maximum_bandwidth_in_mbps = var.load_balancer_shape_details_maximum_bandwidth_in_mbps
    minimum_bandwidth_in_mbps = var.load_balancer_shape_details_minimum_bandwidth_in_mbps
  }
  network_security_group_ids = [ var.lb_nsg_id ]

  display_name = var.lb_name
}

### Blue Backend set

resource "oci_load_balancer_backend_set" "app1-bs-blue" {
  name             = "app1-bs-blue"
  load_balancer_id = oci_load_balancer.flex_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.lb_checker_health_port_app2
    protocol            = "HTTP"
    response_body_regex = ""
    url_path            = var.lb_checker_url_path
  }
}

resource "oci_load_balancer_backend_set" "app2-bs-blue" {
  name             = "app2-bs-blue"
  load_balancer_id = oci_load_balancer.flex_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.lb_checker_health_port_app2
    protocol            = "HTTP"
    response_body_regex = ""
    url_path            = var.lb_checker_url_path
  }
}

### Green Backend set

resource "oci_load_balancer_backend_set" "app1-bs-green" {
  name             = "app1-bs-green"
  load_balancer_id = oci_load_balancer.flex_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.lb_checker_health_port_app1
    protocol            = "HTTP"
    response_body_regex = ""
    url_path            = var.lb_checker_url_path
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
  }

}

resource "oci_load_balancer_backend_set" "app2-bs-green" {
  name             = "app2-bs-green"
  load_balancer_id = oci_load_balancer.flex_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.lb_checker_health_port_app2
    protocol            = "HTTP"
    response_body_regex = ""
    url_path            = var.lb_checker_url_path
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
  }
}

### Blue Backend
resource "oci_load_balancer_backend" "app1-backend-blue" {
  count = length(var.private_ips_blue)  
  load_balancer_id = oci_load_balancer.flex_lb.id
  backendset_name  = oci_load_balancer_backend_set.app1-bs-blue.name
  ip_address       = element(var.private_ips_blue, count.index)
  port             = var.lb_backend_port_app1
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "app2-backend-blue" {
  count = length(var.private_ips_blue)  
  load_balancer_id = oci_load_balancer.flex_lb.id
  backendset_name  = oci_load_balancer_backend_set.app2-bs-blue.name
  ip_address       = element(var.private_ips_blue, count.index)
  port             = var.lb_backend_port_app2
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

### Green  Backend

resource "oci_load_balancer_backend" "app1-backend-green" {
  count = length(var.private_ips_green)  
  load_balancer_id = oci_load_balancer.flex_lb.id
  backendset_name  = oci_load_balancer_backend_set.app1-bs-green.name
  ip_address       = element(var.private_ips_green, count.index)
  port             = var.lb_backend_port_app1
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "app2-backend-green" {
  count = length(var.private_ips_green)  
  load_balancer_id = oci_load_balancer.flex_lb.id
  backendset_name  = oci_load_balancer_backend_set.app2-bs-green.name
  ip_address       = element(var.private_ips_green, count.index)
  port             = var.lb_backend_port_app2
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}



### Blue Listener
resource "oci_load_balancer_listener" "blue-listener" {
  load_balancer_id         = oci_load_balancer.flex_lb.id
  name                     = "http-lsnr-blue"
  default_backend_set_name = oci_load_balancer_backend_set.app1-bs-blue.name
  port                     = var.lb_listener_port_blue
  protocol                 = "HTTP"
  routing_policy_name      = oci_load_balancer_load_balancer_routing_policy.blue_policy.name
  connection_configuration {
    idle_timeout_in_seconds = "10"
  }
}

### Green Listener

resource "oci_load_balancer_listener" "green-listener" {
  load_balancer_id         = oci_load_balancer.flex_lb.id
  name                     = "http-lsnr-green"
  default_backend_set_name = oci_load_balancer_backend_set.app1-bs-green.name
  port                     = var.lb_listener_port_green
  protocol                 = "HTTP"
  routing_policy_name      = oci_load_balancer_load_balancer_routing_policy.green_policy.name

  connection_configuration {
    idle_timeout_in_seconds = "10"
  }
}

### Active Listener


resource "oci_load_balancer_listener" "active-listener" {
  load_balancer_id         = oci_load_balancer.flex_lb.id
  name                     = "http-lsnr-active"
  default_backend_set_name = var.active_environment == "blue" ? oci_load_balancer_backend_set.app1-bs-blue.name: oci_load_balancer_backend_set.app1-bs-green.name
  port                     = var.lb_listener_port_active
  protocol                 = "HTTP"
  routing_policy_name      = oci_load_balancer_load_balancer_routing_policy.blue_green_policy.name
  connection_configuration {
    idle_timeout_in_seconds = "10"
  }
}

########## Routing Policy

### Blue  Routing Policy


resource "oci_load_balancer_load_balancer_routing_policy" "blue_policy" {
  load_balancer_id = oci_load_balancer.flex_lb.id
  name             = "blue_policy"
  condition_language_version = "V1"

  rules {
    condition = "http.request.url.path sw '/app1/'"
    name      = "app1_rule"
    actions {
      name              = "FORWARD_TO_BACKENDSET"
      backend_set_name  = oci_load_balancer_backend_set.app1-bs-blue.name
       
    }
  }
  rules {

   condition = "http.request.url.path sw '/app2/'"
    name      = "app2_rule"
    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = oci_load_balancer_backend_set.app2-bs-blue.name
    }
  }

  # catch-all rule
  rules {
  condition = "http.request.url.path sw '/'"

    name      = "default_app1_rule"
    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = oci_load_balancer_backend_set.app1-bs-blue.name
    }
  }
}


### Green  Routing Policy


resource "oci_load_balancer_load_balancer_routing_policy" "green_policy" {
  load_balancer_id = oci_load_balancer.flex_lb.id
  name             = "green_policy"
  condition_language_version = "V1"

  rules {
    condition = "http.request.url.path sw '/app1/'"
    name      = "app1_rule"
    actions {
      name              = "FORWARD_TO_BACKENDSET"
      backend_set_name  = oci_load_balancer_backend_set.app1-bs-green.name
       
    }
  }
  rules {

   condition = "http.request.url.path sw '/app2/'"
    name      = "app2_rule"
    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = oci_load_balancer_backend_set.app2-bs-green.name
    }
  }

  # catch-all rule
  rules {
  condition = "http.request.url.path sw '/'"

    name      = "default_app1_rule"
    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = oci_load_balancer_backend_set.app1-bs-green.name
    }
  }
}


### Blue-Green / Active Policy

resource "oci_load_balancer_load_balancer_routing_policy" "blue_green_policy" {
  load_balancer_id = oci_load_balancer.flex_lb.id
  name             = "blue_green_policy"
  condition_language_version = "V1"

  # lifecycle {
  #   create_before_destroy = true
  #   ignore_changes = [
  #     # Ignore changes to backend set names unless active_environment changes
  #   ]
  # }

  rules {
    condition = "http.request.url.path sw '/app1/'"
    name      = "app1_rule"
    actions {
      name              = "FORWARD_TO_BACKENDSET"
      backend_set_name  = var.active_environment == "blue" ?  oci_load_balancer_backend_set.app1-bs-blue.name : oci_load_balancer_backend_set.app1-bs-green.name
      
    }
  }
  rules {

   condition = "http.request.url.path sw '/app2/'"
    name      = "app2_rule"
    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name  = var.active_environment == "blue" ?  oci_load_balancer_backend_set.app2-bs-blue.name : oci_load_balancer_backend_set.app2-bs-green.name
    }
  }

  # catch-all rule
  rules {
  condition = "http.request.url.path sw '/'"

    name      = "default_app1_rule"
    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = var.active_environment == "blue" ?  oci_load_balancer_backend_set.app1-bs-blue.name : oci_load_balancer_backend_set.app1-bs-green.name
    }
  }
}
