resource null_resource vault_init_wait {
  depends_on = ["module.vault"]
  provisioner "local-exec" {
    command = "sleep 120s"
  }
}

data google_compute_instance_group vault_poc_mig {
  depends_on = ["null_resource.vault_init_wait"]
  name = "${replace(module.vault.instance_group, "/(.*instanceGroups/)/", "")}"
  zone = "${var.google_default_zone}"
}

data google_compute_instance vault_instances {
  //count = "${length(data.google_compute_instance_group.vault_poc_mig.instances)}"
  //name  = "${element(data.google_compute_instance_group.vault_poc_mig.instances, count.index)}"
  name  = "${replace(data.google_compute_instance_group.vault_poc_mig.instances[0], "/(.*instances/)/", "")}"
  zone  = "${var.google_default_zone}"
}

data google_storage_object_signed_url vault_init_data {
  bucket    = "vault-poc-${random_id.vault_key_name_suffix.hex}-assets"
  path      = "vault_unseal_keys.txt.encrypted"
  duration  = "300s"
}

data external vault_init_data {
  program = ["bash", "${path.module}/scripts/fetch_vault_encrypted_keys.sh"]
  query = {
    signed_url = "${data.google_storage_object_signed_url.vault_init_data.signed_url}"
  }
}

data google_kms_secret vault_init_data {
  crypto_key = "${google_kms_crypto_key.vault_poc.id}"
  ciphertext = "${data.external.vault_init_data.result["encrypted_data"]}"
}

data external vault_root {
  program = ["bash", "${path.module}/scripts/vault_init.sh"]
  query = {
    vault_address   = "${data.google_compute_instance.vault_instances.0.network_interface.0.access_config.0.nat_ip}"
    google_project  = "${var.google_default_project}"
    key_data        = "${data.google_kms_secret.vault_init_data.plaintext}"
  }
}
