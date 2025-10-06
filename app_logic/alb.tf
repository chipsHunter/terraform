#----------TargetGroup------------------#
resource "yandex_alb_target_group" "kuber_host" {
  name = var.kuber_target_host_name

  target {
    subnet_id  = data.terraform_remote_state.infra.outputs.private_created_subnets_info["private-app"].id
    ip_address = data.terraform_remote_state.infra.outputs.app_ipv4
  }
}
#----------BACKENDS---------------------#
resource "yandex_alb_backend_group" "frontend" {
  name = var.backend_group["frontend"].name

  http_backend {
    name             = var.backend_group["frontend"].name
    weight           = 1
    port             = var.backend_group["frontend"].port
    target_group_ids = [yandex_alb_target_group.kuber_host.id]
    healthcheck {
      timeout  = "3s"
      interval = "5s"
      http_healthcheck {
        path = var.backend_group["frontend"].path
      }
    }
    http2 = false
  }
}

resource "yandex_alb_backend_group" "backend" {
  name = var.backend_group["backend"].name

  http_backend {
    name             = var.backend_group["backend"].name
    weight           = 1
    port             = var.backend_group["backend"].port
    target_group_ids = [yandex_alb_target_group.kuber_host.id]
    http2            = false
    healthcheck {
      timeout  = "3s"
      interval = "5s"
      http_healthcheck { path = "/api/v1/posts" }
    }
  }
}

#---------Router-----------------#
resource "yandex_alb_http_router" "main_router" {
  name = "main-http-router"
}

#---------Virtual Host----------#
resource "yandex_alb_virtual_host" "main_virtual_host" {
  name           = "main-virtual-host"
  http_router_id = yandex_alb_http_router.main_router.id
  authority      = ["*"]

  route {
    name = "backend-route"
    http_route {
      http_match {
        path {
          prefix = var.backend_group["backend"].path
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend.id
      }
    }
  }
  route {
    name = "frontend-route"
    http_route {
      http_match {
        path {
          prefix = var.backend_group["frontend"].path
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.frontend.id
      }
    }
  }
}

#---------Load Balancer----------#
resource "yandex_alb_load_balancer" "main_alb" {
  name       = "main-load-balancer"
  network_id = data.terraform_remote_state.infra.outputs.net_id

  allocation_policy {
    location {
      zone_id   = var.zone
      subnet_id = data.terraform_remote_state.infra.outputs.public_created_subnets_info.id
    }
  }

  security_group_ids = [data.terraform_remote_state.infra.outputs.alb_sg.id]

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.main_router.id
      }
    }
  }
}
