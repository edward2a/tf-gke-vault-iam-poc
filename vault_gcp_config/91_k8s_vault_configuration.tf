resource vault_auth_backend kubernetes {
  type = "kubernetes"
}

resource vault_kubernetes_auth_backend_config gke {
  backend             = "${vault_auth_backend.kubernetes.path}"
  kubernetes_host     = "https://${data.terraform_remote_state.gcp.kubernetes_host}"
  kubernetes_ca_cert  = "${data.terraform_remote_state.gcp.kubernetes_vault_sa_ca_cert}"
  token_reviewer_jwt  = "${data.terraform_remote_state.gcp.kubernetes_vault_sa_jwt}"
}

resource vault_kubernetes_auth_backend_role gke {
  backend                           = "${vault_auth_backend.kubernetes.path}"
  role_name                         = "gke-auth"
  bound_service_account_names       = ["sample-app-1", "sample-app-2"]
  bound_service_account_namespaces  = ["sample-app-1", "sample-app-2"]
  #ttl                               = 3600
  #max_ttl                           = 86400
  period                            = 3600
  policies                          = ["default"]
}
