
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
  region            = "${var.google_default_region}"
  zone              = "${var.google_default_zone}"
  network           = "${google_compute_network.kubault_poc.name}"
  subnetwork        = "${google_compute_subnetwork.kubault_poc_1.name}"
  kms_keyring_name  = "${google_kms_key_ring.vault_poc.name}"

  storage_bucket    = "vault-poc"
  force_destroy_bucket = "true"

  vault_version     = "1.0.2"

}

#### GKE ####

module gke {
  source = "./modules/gcp/gke"

  project_id          = "${var.google_default_project}"
  name                = "kube-poc"
  region              = "${var.google_default_region}"

  network             = "${google_compute_network.kubault_poc.name}"
  subnetwork          = "${google_compute_subnetwork.kubault_poc_1.name}"
  ip_range_pods       = "${google_compute_subnetwork.kubault_poc_1.secondary_ip_range.range_name}"
  ip_range_services   = "${google_compute_subnetwork.kubault_poc_1.secondary_ip_range.range_name}"
}

#### GITLAB ####

module gitlab {
  source = "./modules/gcp/gitlab"

  project     = "${var.google_default_project}"
  prefix      = "gl-poc"

  region      = "${var.google_default_region}"
  zone        = "${var.google_default_zone}"
  network     = "${google_compute_network.kubault_poc.self_link}"
  subnetwork  = "${google_compute_subnetwork.kubault_poc_1.self_link}"

  ssh_key     = "./ssh_key/id_rsa"
  data_volume = "gitlab-poc-data"
  config_file = ""
  dns_name    = "gitlab"
  dns_zone    = "no_dns"

  runner_count = 0
}
