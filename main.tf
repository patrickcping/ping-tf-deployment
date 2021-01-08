resource "kubernetes_secret" "ping_devops" {
  metadata {
    name      = "${var.prefix}-${var.devops_secret_name}"
    namespace = var.devops_k8s_namespace
    labels = {
      "managed-by" = "Terraform"
    }
  }

  data = {
    PING_IDENTITY_DEVOPS_KEY = var.devops_key
    PING_IDENTITY_DEVOPS_USER = var.devops_user
    PING_IDENTITY_ACCEPT_EULA = var.ping_accept_eula
  }

  type = "Opaque"
}

resource "kubernetes_secret" "ping_tls" {
  metadata {
    name      = "${var.prefix}-${var.tls_secret_name}"
    namespace = var.devops_k8s_namespace
    labels = {
      "managed-by" = "Terraform"
    }
  }

  data = {
    "tls.crt" = var.tls_crt
    "tls.key" = var.tls_key
  }

  type = "kubernetes.io/tls"
}

resource "helm_release" "ping_devops" {

  name             = var.prefix
  repository       = var.ping_helm_repo
  chart            = var.ping_helm_chart
  version          = var.ping_helm_chart_version
  create_namespace = false
  namespace        = var.devops_k8s_namespace
  lint             = true

  values = [
    file(var.ping_helm_values_file)
  ]

  set {
    name  = "global.labels.managed-by"
    value = "Terraform"
  }
  
  set {
    name  = "global.ingress.defaultTlsSecret"
    value = kubernetes_secret.ping_tls.metadata[0].name
  }

  set {
    name  = "global.license.secret.devOps"
    value = kubernetes_secret.ping_devops.metadata[0].name
  }

  timeout = 600

}