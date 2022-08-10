variable "new_relic_license" {
  type = string
}

variable "pixie_api_key" {
  type = string
}

variable "pixie_chart_deploy_key" {
  type = string
}

locals {
  client_certificate     = base64decode(azurerm_kubernetes_cluster.gbc.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.gbc.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.gbc.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.gbc.kube_config.0.host

    client_certificate     = local.client_certificate
    client_key             = local.client_key
    cluster_ca_certificate = local.cluster_ca_certificate
  }
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.gbc.kube_config.0.host

  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "new_relic" {
  metadata {
    name = "new-relic"
  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }
}

resource "kubernetes_namespace" "stage" {
  metadata {
    name = "stage"
  }
}

resource "helm_release" "nginx_ingress" {
  name = var.name_prefix

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  namespace  = kubernetes_namespace.ingress.metadata.0.name

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "service.loadBalancerIP"
    value = azurerm_public_ip.gbc.ip_address
  }

  set {
    name  = "replicaCount"
    value = 3
  }

}

resource "helm_release" "cert-manager" {
  name = var.name_prefix

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata.0.name

  set {
    name  = "installCRDs"
    value = true
  }
}

resource "helm_release" "vault" {
  name = var.name_prefix

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.metadata.0.name

  set {
    name  = "ui.enabled"
    value = true
  }
}

# resource "helm_release" "new_relic" {
#   name = var.name_prefix

#   repository = "https://helm-charts.newrelic.com"
#   chart      = "nri-bundle"
#   namespace  = kubernetes_namespace.new_relic.metadata.0.name

#   set {
#     name  = "global.licenseKey"
#     value = var.new_relic_license
#   }

#   set {
#     name  = "global.cluster"
#     value = var.name_prefix
#   }

#   set {
#     name  = "newrelic-infrastructure.privileged"
#     value = true
#   }

#   # Metrics
#   set {
#     name  = "ksm.enabled"
#     value = true
#   }

#   set {
#     name  = "prometheus.enabled"
#     value = true
#   }

#   set {
#     name  = "kubeEvents.enabled"
#     value = true
#   }

#   set {
#     name  = "logging.enabled"
#     value = true
#   }

#   set {
#     name  = "newrelic-pixie.enabled"
#     value = false
#   }

#   set {
#     name  = "newrelic-pixie.apiKey"
#     value = var.pixie_api_key
#   }

#   set {
#     name  = "pixie-chart.enabled"
#     value = false
#   }

#   set {
#     name  = "pixie-chart.deployKey"
#     value = var.pixie_chart_deploy_key
#   }

#   set {
#     name  = "pixie-chart.clusterName"
#     value = var.name_prefix
#   }

# }