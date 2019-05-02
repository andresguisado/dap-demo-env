provider "conjur" {}

data "conjur_secret" "db_uname" {
  name = "cicd-secrets/prod-db-username"
}

data "conjur_secret" "db_pwd" {
  name = "cicd-secrets/prod-db-password"
}

output "db_pwd" {
  sensitive = true
  value     = "${data.conjur_secret.db_pwd.value}"
}

output "db_uname" {
  value     = "${data.conjur_secret.db_uname.value}"
}

