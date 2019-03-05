data terraform_remote_state gcp {
  backend = "local"
  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}
