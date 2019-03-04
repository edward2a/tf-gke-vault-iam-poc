output vault_endpoint {
  value = "${data.google_compute_instance.vault_instances.0.network_interface.0.access_config.0.nat_ip}"
}

output vault_root_token {
  sensitive = true
  value = "${data.external.vault_root.result["root_token"]}"
}

output google_project_id {
  value = "${var.google_default_project}"
}


output kubernetes_vault_sa_ca_cert {
  sensitive = true
  value = "${data.kubernetes_secret.vault_sa.data.ca.crt}"
}

output kubernetes_vault_sa_jwt {
  sensitive  = true
  value = "${data.kubernetes_secret.vault_sa.data.token}"
}

