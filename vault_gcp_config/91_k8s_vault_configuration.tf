resource vault_auth_backend kubernetes {
  type = "kubernetes"
}

resource vault_kubernetes_auth_backend_config gke {
  backend             = "${vault_auth_backend.kubernetes.path}"
  kubernetes_host     = "https://${data.terraform_remote_state.gcp.kubernetes_host}"
  kubernetes_ca_cert  = "${data.terraform_remote_state.gcp.kubernetes_vault_sa_ca_cert}"
  token_reviewer_jwt  = "${data.terraform_remote_state.gcp.kubernetes_vault_sa_jwt}"
}

resource vault_policy sample_app_1 {
  name = "sample-app-1"
  policy = <<EOT
path  "gcp/token/sample-app-1" {
  capabilities = ["read"]
}
EOT
}

resource vault_policy sample_app_2 {
  name = "sample-app-2"
  policy = <<EOT
path  "gcp/token/sample-app-2" {
  capabilities = ["read"]
}
EOT
}

resource vault_kubernetes_auth_backend_role sample_app_1 {
  backend                           = "${vault_auth_backend.kubernetes.path}"
  role_name                         = "sample-app-1"
  bound_service_account_names       = ["sample-app-1"]
  bound_service_account_namespaces  = ["sample-app-1"]
  #ttl                               = 3600
  #max_ttl                           = 86400
  period                            = 3600
  policies                          = ["sample-app-1"]
}

resource vault_kubernetes_auth_backend_role sample_app_2 {
  backend                           = "${vault_auth_backend.kubernetes.path}"
  role_name                         = "sample-app-2"
  bound_service_account_names       = ["sample-app-2"]
  bound_service_account_namespaces  = ["sample-app-2"]
  #ttl                               = 3600
  #max_ttl                           = 86400
  period                            = 3600
  policies                          = ["sample-app-2"]
}

