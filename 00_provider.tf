provider "google-beta" {
  version     = "~> 2.1.0"
  credentials = "${var.google_credentials}"
  project     = "${var.google_default_project}"
  region      = "${var.google_default_region}"
  zone        = "${var.google_default_zone}"
}

provider "google" {
  version     = "~> 2.1.0"
  credentials = "${var.google_credentials}"
  project     = "${var.google_default_project}"
  region      = "${var.google_default_region}"
  zone        = "${var.google_default_zone}"
}
