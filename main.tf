resource "kubernetes_secret" "ping_devops" {
  metadata {
    name      = "${var.prefix}-${var.devops_secret_name}"
    namespace = var.devops_k8s_namespace
    labels = {
      "managed-by" = "Terraform"
    }
  }

  data = {
    PING_IDENTITY_DEVOPS_KEY  = var.devops_key
    PING_IDENTITY_DEVOPS_USER = var.devops_user
    PING_IDENTITY_ACCEPT_EULA = var.ping_accept_eula
  }

  type = "Opaque"
}

resource "tls_private_key" "ping_devops" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "ping_devops" {
  key_algorithm   = tls_private_key.ping_devops.algorithm
  private_key_pem = tls_private_key.ping_devops.private_key_pem

  # Certificate expires after 12 hours.
  validity_period_hours = 12

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
      "key_encipherment",
      "digital_signature",
      "server_auth",
  ]

  dns_names = ["localhost", var.domain_suffix, "*.${var.prefix}.${var.domain_suffix}"]

  subject {
      common_name  = "${var.prefix}.${var.domain_suffix}"
      organization = "Ping Identity"
      organizational_unit = "SA"
      country = "GB"
  }
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
    "tls.crt" = var.tls_crt != "" ? var.tls_crt : tls_self_signed_cert.ping_devops.cert_pem
    "tls.key" = var.tls_key != "" ? var.tls_key : tls_private_key.ping_devops.private_key_pem
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_config_map" "ping_devops" {
  metadata {
    name = "${var.prefix}-${var.ping_helm_name}-global"
    namespace = var.devops_k8s_namespace
    labels = {
      "managed-by" = "Terraform"
    }
  }

  data = {
    PF_ADMIN_INTERNAL_HOSTNAME  = "${var.prefix}-${var.ping_helm_name}-pingfederate-admin"
    PF_ADMIN_INTERNAL_PORT      = "9999"
    PF_ADMIN_EXTERNAL_HOSTNAME  = "pingfederate-admin.${var.prefix}.${var.domain_suffix}"
    PF_ENGINE_EXTERNAL_HOSTNAME = "pingfederate-engine.${var.prefix}.${var.domain_suffix}"
    PF_ENGINE_EXTERNAL_PORT     = "443"
    PA_ENGINE_EXTERNAL_HOSTNAME = "pingaccess-engine.${var.prefix}.${var.domain_suffix}"
    PA_ENGINE_EXTERNAL_PORT     = "443"
    PA_ADMIN_INTERNAL_HOSTNAME  = "${var.prefix}-${var.ping_helm_name}-pingaccess-admin"
    PA_ADMIN_EXTERNAL_HOSTNAME  = "pingaccess-admin.${var.prefix}.${var.domain_suffix}"
  }
}

resource "helm_release" "ping_devops" {

  name             = "${var.prefix}-${var.ping_helm_name}"
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
    name  = "global.ingress.enabled"
    value = "true"
  }
  
  set {
    name  = "global.ingress.addReleaseNameToHost"
    value = "none"
  }

  set {
    name  = "global.ingress.defaultDomain"
    value = "${var.prefix}.${var.domain_suffix}"
  }

  set {
    name  = "global.license.secret.devOps"
    value = kubernetes_secret.ping_devops.metadata[0].name
  }

  set {
    name  = "global.container.envFrom[0].configMapRef.name"
    value = kubernetes_config_map.ping_devops.metadata[0].name
  }

  ## PF
  set {
    name  = "pingfederate-admin.enabled"
    value = var.pf_enabled
  }

  set {
    name  = "pingfederate-admin.image.tag"
    value = var.pf_tag
  }

  set {
    name  = "pingfederate-admin.envs.SERVER_PROFILE_URL"
    value = var.pf_config_repo
  }

  set {
    name  = "pingfederate-admin.envs.SERVER_PROFILE_PATH"
    value = var.pf_config_path
  }

  set {
    name  = "pingfederate-engine.enabled"
    value = var.pf_enabled
  }

  set {
    name  = "pingfederate-engine.image.tag"
    value = var.pf_tag
  }

  set {
    name  = "pingfederate-engine.envs.SERVER_PROFILE_URL"
    value = var.pf_config_repo
  }

  set {
    name  = "pingfederate-engine.envs.SERVER_PROFILE_PATH"
    value = var.pf_config_path
  }

  ## PA
  set {
    name  = "pingaccess-admin.enabled"
    value = var.pa_enabled
  }

  set {
    name  = "pingaccess-admin.image.tag"
    value = var.pa_tag
  }

  set {
    name  = "pingaccess-admin.envs.SERVER_PROFILE_URL"
    value = var.pa_config_repo
  }

  set {
    name  = "pingaccess-admin.envs.SERVER_PROFILE_PATH"
    value = var.pa_config_path
  }

  set {
    name  = "pingaccess-engine.enabled"
    value = var.pa_enabled
  }

  set {
    name  = "pingaccess-engine.image.tag"
    value = var.pa_tag
  }

  set {
    name  = "pingaccess-engine.envs.SERVER_PROFILE_URL"
    value = var.pa_config_repo
  }

  set {
    name  = "pingaccess-engine.envs.SERVER_PROFILE_PATH"
    value = var.pa_config_path
  }

  ## PD
  set {
    name  = "pingdirectory.enabled"
    value = var.pd_enabled
  }

  set {
    name  = "pingdirectory.image.tag"
    value = var.pd_tag
  }

  set {
    name  = "pingdirectory.envs.SERVER_PROFILE_URL"
    value = var.pd_config_repo
  }

  set {
    name  = "pingdirectory.envs.SERVER_PROFILE_PATH"
    value = var.pd_config_path
  }

  set {
    name  = "pingdataconsole.enabled"
    value = var.pd_enabled
  }

  set {
    name  = "pingdataconsole.image.tag"
    value = var.pd_tag
  }

  timeout = 600

}