provider kubernetes {
  host                      = "https://${module.gke.endpoint}"

  config_context_auth_info  = "kubault-poc"
  config_context_cluster    = "kubault-poc"
}
