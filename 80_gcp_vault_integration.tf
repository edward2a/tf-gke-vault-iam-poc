# Wait resource to make sure vault is ready
resource null_resource vault_init_wait {
  depends_on = ["module.vault"]
  provisioner "local-exec" {
    command = "sleep 120s"
  }
}

# Info on the vault MIG for the next resource
data google_compute_instance_group vault_poc_mig {
  depends_on = ["null_resource.vault_init_wait"]
  name = "${replace(module.vault.instance_group, "/(.*instanceGroups/)/", "")}"
  zone = "${var.google_default_zone}"
}

# Get the current endpoint (this should be superseded by a load balancer)
data google_compute_instance vault_instances {
  //count = "${length(data.google_compute_instance_group.vault_poc_mig.instances)}"
  //name  = "${element(data.google_compute_instance_group.vault_poc_mig.instances, count.index)}"
  name  = "${replace(data.google_compute_instance_group.vault_poc_mig.instances[0], "/(.*instances/)/", "")}"
  zone  = "${var.google_default_zone}"
}

# Create a signed URL to retrive the vault keys
data google_storage_object_signed_url vault_init_data {
  depends_on  = ["module.vault", "null_resource.vault_init_wait"]
  bucket      = "vault-poc-${random_id.vault_key_name_suffix.hex}-assets"
  path        = "vault_unseal_keys.txt.encrypted"
  duration    = "300s"
}

# Fetch the vault keys with a helper script
data external vault_init_data {
  depends_on  = ["module.vault", "null_resource.vault_init_wait", "data.google_storage_object_signed_url.vault_init_data"]
  program     = ["bash", "${path.module}/scripts/fetch_vault_encrypted_keys.sh"]
  query       = {
    signed_url = "${data.google_storage_object_signed_url.vault_init_data.signed_url}"
  }
}

# Declaring a data source for the key because for some reason using the actual
# resource gives an error which is magically fixed on retry (bug?)
data google_kms_crypto_key vault_poc {
  depends_on = ["null_resource.vault_init_wait"]
  name      = "vault-poc-${random_id.vault_key_name_suffix.hex}"
  key_ring  = "${google_kms_key_ring.vault_poc.self_link}"
}

# Decryption of that from the external source
data google_kms_secret vault_init_data {
  crypto_key = "${data.google_kms_crypto_key.vault_poc.self_link}"
  ciphertext = "${data.external.vault_init_data.result["encrypted_data"]}"
}

# Initialisation of vault and return of the root key for further use
data external vault_root {
  program = ["bash", "${path.module}/scripts/vault_init.sh"]
  query = {
    vault_address   = "${data.google_compute_instance.vault_instances.0.network_interface.0.access_config.0.nat_ip}"
    google_project  = "${var.google_default_project}"
    key_data        = "${data.google_kms_secret.vault_init_data.plaintext}"
  }
}

