
provider kubernetes {
  host                      = "https://${module.gke.endpoint}"

  config_context_auth_info  = "kubault-poc"
  config_context_cluster    = "kubault-poc"

  client_certificate        = "${base64decode(module.gke.master_client_certificate)}"
  client_key                = "${base64decode(module.gke.master_client_key)}"
  cluster_ca_certificate    = "${base64decode(module.gke.ca_certificate)}"
  username                  = "${module.gke.master_username}"
  password                  = "${module.gke.master_password}"
}


# Vault service account
resource kubernetes_service_account vault {
  metadata {
    name      = "vault-authenticator"
    namespace = "default"
  }
}

# Vault cluster role binding
resource kubernetes_cluster_role_binding vault {
  metadata {
    name      = "vault-tokenreview-binding"
  }
  role_ref {
    name      = "system-auth:delegator"
    kind      = "ClusterRole"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    name      = "${kubernetes_service_account.vault.metadata.0.name}"
    kind      = "ServiceAccount"
    namespace = "default"
    api_group = ""
  }
}

