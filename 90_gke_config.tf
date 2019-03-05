data google_container_cluster gke {
  name = "${module.gke.name}"
  zone = "${var.google_default_zone}"
}

provider kubernetes {
  host                      = "https://${module.gke.endpoint}"

  config_context_auth_info  = "kubault-poc"
  config_context_cluster    = "kubault-poc"

//  client_certificate        = "${base64decode(module.gke.master_client_certificate)}"
//  client_key                = "${base64decode(module.gke.master_client_key)}"
  cluster_ca_certificate    = "${base64decode(module.gke.ca_certificate)}"
  username                  = "${data.google_container_cluster.gke.master_auth.0.username}"
  password                  = "${data.google_container_cluster.gke.master_auth.0.password}"
}

#### K8S CONFIG FOR VAULT - BEGIN ####
# Vault service account
resource kubernetes_service_account vault {
  metadata {
    name      = "vault-authenticator"
    namespace = "default"
  }
}

# Vault SA data for export
data kubernetes_secret vault_sa {
  metadata = {
    name      = "${kubernetes_service_account.vault.default_secret_name}"
    namespace = "default"
  }
}

# Vault cluster role binding
resource kubernetes_cluster_role_binding vault {
  metadata {
    name      = "vault-tokenreview-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.vault.metadata.0.name}"
    namespace = "default"
  }
}
#### K8S CONFIG FOR VAULT - END ####


#### K8S CONFIG FOR SAMPLE APPS - BEGIN ####
resource kubernetes_namespace sample_app_1 {
  metadata {
    name = "sample-app-1"
  }
}

resource kubernetes_namespace sample_app_2 {
  metadata {
    name = "sample-app-2"
  }
}

resource kubernetes_service_account sample_app_1 {
  metadata {
    name  = "sample-app-1"
    namespace = "${kubernetes_namespace.sample_app_1.id}"
  }
  automount_service_account_token = "true"
}

resource kubernetes_service_account sample_app_2 {
  metadata {
    name  = "sample-app-2"
    namespace = "${kubernetes_namespace.sample_app_2.id}"
  }
  automount_service_account_token = "true"
}

#### K8S CONFIG FOR SAMPLE APPS - END ####

#### K8S MANAGERS FOR SAMPLE APPS - BEGIN ####
resource kubernetes_service_account mgr_app_1 {
  metadata {
    name  = "mgr-app-1"
    namespace = "${kubernetes_namespace.sample_app_1.id}"
  }
  automount_service_account_token = "true"
}

resource kubernetes_service_account mgr_app_2 {
  metadata {
    name  = "mgr-app-2"
    namespace = "${kubernetes_namespace.sample_app_2.id}"
  }
  automount_service_account_token = "true"
}

resource kubernetes_role mgr_app_1 {
  metadata {
    name = "mgr-app-1"
    namespace = "${kubernetes_namespace.sample_app_1.id}"
  }
  rule {
    api_groups  = ["", "extensions", "apps"]
    resources   = ["deployments", "replicasets", "pods"]
    verbs       = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource kubernetes_role mgr_app_2 {
  metadata {
    name = "mgr-app-2"
    namespace = "${kubernetes_namespace.sample_app_2.id}"
  }
  rule {
    api_groups  = ["", "extensions", "apps"]
    resources   = ["deployments", "replicasets", "pods"]
    verbs       = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource kubernetes_role_binding mgr_app_1 {
  metadata {
    name = "mgr-app-1"
    namespace = "${kubernetes_namespace.sample_app_1.id}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "mgr-app-1"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "mgr-app-1"
    namespace = "${kubernetes_namespace.sample_app_1.id}"
  }
}

resource kubernetes_role_binding mgr_app_2 {
  metadata {
    name = "mgr-app-2"
    namespace = "${kubernetes_namespace.sample_app_2.id}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "mgr-app-2"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "mgr-app-2"
    namespace = "${kubernetes_namespace.sample_app_2.id}"
  }
}
#### K8S MANAGERS FOR SAMPLE APPS - END ####
