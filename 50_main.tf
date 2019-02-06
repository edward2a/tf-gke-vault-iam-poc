
#### VAULT ####

# vault keyring
resource google_kms_key_ring vault_poc {
  name     = "vault-poc"
  location = "global"
}

# vault key
resource google_kms_crypto_key vault_poc {
  name            = "vault-poc"
  key_ring        = "${google_kms_key_ring.vault_poc.self_link}"
  rotation_period = "100000s"
}

module vault {
  source = "./modules/gcp/vault"

  project_id        = "${var.google_default_project}"
  storage_bucket    = ""
  region            = "${var.google_default_region}"
  zone              = "${var.google_default_zone}"
  kms_keyring_name  = "${google_kms_key_ring.vault_poc.name}"
}

#### GKE ####

module gke {
  source = "./modules/gcp/gke"

  project_id          = "${var.google_default_project}"
  name                = "kube-poc"
  region              = "${var.google_default_region}"

  network             = "${google_compute_network.kubault_poc.self_link}"
  subnetwork          = "${google_compute_subnetwork.kubault_poc_1.self_link}"
  ip_range_pods       = "kubault-poc-1"
  ip_range_services   = "kubault-poc-1"
  // ip_range_pods       = "${google_compute_subnetwork.kubault_poc_1.secondary_ip_range.ip_cidr_range}"
  // ip_range_services   = "${google_compute_subnetwork.kubault_poc_1.secondary_ip_range.ip_cidr_range}"
}


#### GITLAB ####
resource random_string gl_runner_token {
  length = 32
}

resrouce random_string gl_initial_root_password {
  length = 32
}

module gitlab {
  source = "./modules/gcp/gitlab"

  project     = "${var.google_default_project}"
  prefix      = "gl-poc"

  ssh_key     = "./ssh_key/id_rsa"
  data_volume = "gitlab-poc-data"
  config_file = ""
  dns_name    = ""

  runner_token = "${random_string.gl_runner_token.result}"
  initial_root_password = "${random_string.gl_initial_root_password.result}"
}
