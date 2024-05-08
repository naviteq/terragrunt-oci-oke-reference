# Locals
locals {
  pwd           = path_relative_to_include()
  stack         = split("/", local.pwd)[2]
  region        = split("/", local.pwd)[1]
  environment   = split("/", local.pwd)[0]
  oracle_inputs = try(yamldecode(file("oracle.yaml")), {})
  tenancy_id    = local.oracle_inputs.tenancy_id
}
remote_state {
  backend = "s3"
  config = {
    bucket                             = "naviteq-oracle-terragrunt-states"
    region                             = local.oracle_inputs.region
    key                                = "terragrunt/${local.environment}/${local.region}/${local.stack}.tfstate"
    force_path_style                   = true
    skip_region_validation             = true
    skip_credentials_validation        = true
    skip_metadata_api_check            = true
    skip_bucket_ssencryption           = true
    skip_bucket_root_access            = true
    skip_bucket_enforced_tls           = true
    skip_bucket_public_access_blocking = true
    endpoint                           = "https://<storage_id>.compat.objectstorage.${local.region}.oraclecloud.com"
  }
}
# Read details about configuration and local setup here:
# https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformUsingObjectStore.htm
generate "provider" {
  path      = "provider.auto.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      backend "s3" {}
      required_version = "~> 1.0"
      required_providers {
        oci = {
          source                = "oracle/oci"
          version               = "~> 5.30"
        }
      }
    }
    provider "oci" {
      tenancy_ocid        = "${local.tenancy_id}"
      config_file_profile = "${get_env("OCI_CLI_PROFILE", "")}"
      region              = "${local.region}"
    }
    provider "oci" {
      alias = "home"
      tenancy_ocid        = "${local.tenancy_id}"
      config_file_profile = "${get_env("OCI_CLI_PROFILE", "")}"
      region              = "${local.region}"
    }
EOF
}
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = ""
}
# Inputs
inputs = local.oracle_inputs
