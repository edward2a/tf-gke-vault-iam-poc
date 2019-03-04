
#### GCP AUTH BACKEND CONFIG - BEGIN ####
#### TODO: un-hard-code this ####
resource google_service_account_key vault_admin {
  service_account_id  = "vault-admin@${var.google_default_project}.iam.gserviceaccount.com"
}

resource vault_gcp_auth_backend gcp {
  credentials = "${base64decode(google_service_account_key.vault_admin.private_key)}"
}
#### GCP AUTH BACKEND CONFIG - END ####


#### GCP SECRET BACKEND CONFIG - BEGIN ####
resource google_service_account vault_secret {
  account_id = "vault-secret"
  display_name = "Vault Secret"
}

resource google_service_account_key vault_secret {
  service_account_id = "${google_service_account.vault_secret.account_id}"
}

resource google_project_iam_member vault_secret_account_admin {
  role = "roles/iam.serviceAccountAdmin"
  member = "serviceAccount:${google_service_account.vault_secret.email}"
}

resource google_project_iam_member vault_secret_account_admin_policies {
  role = "roles/resourcemanager.projectIamAdmin"
  member = "serviceAccount:${google_service_account.vault_secret.email}"
}

resource google_project_iam_member vault_secret_account_admin_keys {
  role = "roles/iam.serviceAccountKeyAdmin"
  member = "serviceAccount:${google_service_account.vault_secret.email}"
}

resource google_project_iam_member vault_secret_account_admin_tokens {
  role = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${google_service_account.vault_secret.email}"
}

resource vault_gcp_secret_backend gcp {
  credentials = "${base64decode(google_service_account_key.vault_secret.private_key)}"
}
#### GCP SECRET BACKEND CONFIG - END ####

#### SAMPLE APPS CONFIG ####
#### Sample application configurations for google and vault ####
/*
resource google_service_account sample_app_1 {
  account_id  = "sample-app-1"
}

resource google_service_account sample_app_2 {
  account_id  = "sample-app-2"
}
*/

resource vault_generic_secret sample_app_1_roleset {
  path = "gcp/roleset/sample-app-1"
  data_json = <<EOT
{
  "project"       : "${data.terraform_remote_state.gcp.google_project_id}",
  "secret_type"   : "access_token",
  "token_scopes"  : "https://www.googleapis.com/auth/devstorage.full_control",
  "bindings"      : "resource \"//cloudresourcemanager.googleapis.com/projects/readme-poc\" { roles = [ \"roles/storage.admin\" ] }"
}
EOT
}

resource vault_generic_secret sample_app_2_roleset {
  path = "gcp/roleset/sample-app-2"
  data_json = <<EOT
{
  "project"       : "${data.terraform_remote_state.gcp.google_project_id}",
  "secret_type"   : "access_token",
  "token_scopes"  : "https://www.googleapis.com/auth/devstorage.full_control",
  "bindings"      : "resource \"//cloudresourcemanager.googleapis.com/projects/readme-poc\" { roles = [ \"roles/storage.admin\" ] }"
}
EOT
}
/*
resource vault_gcp_auth_backend_role sample_app_1 {
  role        = ""
  type        = "iam"
  project_id  = "${data.terraform_remote_state.gcp.google_project_id}"
  period      = 3600
  policies    = [""]
}
*/
