provider "google-beta" {
  version     = "~> 1.20.0"
  credentials = "${var.google_credentials}"
  project     = "${var.google_default_project}"
  region      = "${var.google_default_region}"
  zone        = "${var.google_default_zone}"
}

provider "google" {
  version     = "~> 1.20.0"
  credentials = "${var.google_credentials}"
  project     = "${var.google_default_project}"
  region      = "${var.google_default_region}"
  zone        = "${var.google_default_zone}"
}

provider vault {
  version = "~> 1.5.0"
  address = "https://${data.terraform_remote_state.gcp.vault_endpoint}"
  token   = "${data.terraform_remote_state.gcp.vault_root_token}"
  #### WARNING: BE A SAFE, BE SANE, DON'T SKIP TLS VERIFY ####
  skip_tls_verify = "true"
}

