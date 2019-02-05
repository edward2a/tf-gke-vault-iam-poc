resource google_compute_network kubault_poc {
  name = "kubault-poc"
  routing_mode = "REGIONAL"
  auto_create_subnetworks = "false"
}

resource google_compute_subnetwork kubault_poc_1 {
  name = "kubault-poc-1"
  region = "${var.google_default_region}"
  network = "${google_compute_network.kubault_poc.self_link}"
  ip_cidr_range = "172.16.200.0/24"
  secondary_ip_range = [{
    range_name = "kubault_poc_1_k8s"
    ip_cidr_range = "172.16.201.0/24"
  }]
  private_ip_google_access = "true"
}


