# We should re-define the OCI home provider for OKE Module,
# because of symlinks used in the remote OKE module
locals {
  override_content = <<-EOF
    terraform {
      required_providers {
        oci = {
          source                = "oracle/oci"
          configuration_aliases = [oci.home]
          version               = "~> 5.30"
        }
      }
    }
EOF
}
generate "iam-versions" {
  path      = "modules/iam/auto.versions.tf"
  if_exists = "overwrite"
  contents  = local.override_content
}
generate "iam-network" {
  path      = "modules/network/auto.versions.tf"
  if_exists = "overwrite"
  contents  = local.override_content
}
generate "iam-cluster" {
  path      = "modules/cluster/auto.versions.tf"
  if_exists = "overwrite"
  contents  = local.override_content
}
