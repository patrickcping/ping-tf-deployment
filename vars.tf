variable "prefix" {

}

variable "domain_suffix" {
    description = "A domain suffix used for all resources."
}

variable "ping_accept_eula" {
    description = "EULA Accepted"
    default = "NO"
}

variable "devops_user" {
  description = "The Ping Devops user ID."
}

variable "devops_key" {
  description = "The Ping Devops key."
}

variable "tls_crt" {
  description = "The B64 encoded TLS wildcard certificate to use in standing up ingresses for the stack."
}

variable "tls_key" {
  description = "The B64 encoded TLS wildcard certificate key to use in standing up ingresses for the stack."
}

variable "devops_secret_name" {
  description = "The kubernetes secret name for the devops secret"
  default     = "devops-secret"
}

variable "tls_secret_name" {
  description = "The kubernetes secret name for the tls secret"
  default     = "tls-secret"
}

variable "devops_k8s_namespace" {
    description = "The namespace to create for Ping deployment"
}

variable "ping_helm_name" {
    description = "The Ping Helm deployment name"
    default     = "ping-devops"
}

variable "ping_helm_repo" {
    description = "The Ping Helm repository"
    default     = "https://helm.pingidentity.com"
}

variable "ping_helm_chart" {
    description = "The Ping Helm chart name"
    default     = "ping-devops"
}

variable "ping_helm_chart_version" {
    description = "The Ping Helm chart version"
    default     = "0.4.2"
}

variable "ping_helm_values_file" {
    description = "The Ping Helm chart values file"
}

## PF
variable "pf_enabled" {
    default = false
}

variable "pf_tag" {
    default = "2101"
}

variable "pf_config_repo" {
    default = "https://github.com/pingidentity/pingidentity-server-profiles.git"
}

variable "pf_config_path" {
    default = "getting-started/pingfederate"
}

## PA
variable "pa_enabled" {
    default = false
}

variable "pa_tag" {
    default = "2101"
}

variable "pa_config_repo" {
    default = "https://github.com/pingidentity/pingidentity-server-profiles.git"
}

variable "pa_config_path" {
    default = "getting-started/pingaccess"
}

## PD
variable "pd_enabled" {
    default = false
}

variable "pd_tag" {
    default = "2101"
}

variable "pd_config_repo" {
    default = "https://github.com/pingidentity/pingidentity-server-profiles.git"
}

variable "pd_config_path" {
    default = "getting-started/pingdirectory"
}