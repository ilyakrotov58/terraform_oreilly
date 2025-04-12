terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.0"
        }
    }
}

resource "kubernetes_deployment" "app" {
    metadata {
        name = var.name
    }

    spec {
        replicas = var.replicas

        template {
            metadata {
              labels = local.pod_labels
            }

            spec {
                container {
                    name = var.name
                    image = var.image

                    port {
                        container_port = var.container_port
                    }

                    dynamic "env" {
                        for_each = var.enviroment_variables
                        content {
                            name = env.key
                            value = env.value
                        }
                    }
                }
            }
        }

        selector {
            match_labels = local.pod_labels
        }
    }
}

resource "kubernetes_service" "app" {
    metadata {
        name = var.name
    }

    spec {
        type = "LoadBalancer"
        port {
            port = 80
            target_port = var.container_port
            protocol = "TCP"
        }
        selector = local.pod_labels
    }
}

output "service_endpoint" {
    value = try(
        "http://${local.status[0]["load_balancer"][0]["ingress"][0]["hostname"]}",
        "(error parsing hostname from status)"
    )

    description = "The k8s Service endpoint"
}

locals {
    pod_labels = {
        app = var.name
    }
}

locals {
    status = kubernetes_service.app.status
}