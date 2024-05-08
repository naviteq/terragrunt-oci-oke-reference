include "oracle" {
  path           = find_in_parent_folders("oracle.hcl")
  merge_strategy = "deep"
}
terraform {
  source = "tfr://registry.terraform.io/oracle-terraform-modules/iam/oci//modules/iam-compartment?version=2.0.3"
}
inputs = {
  compartment_create = true
  enable_delete      = true
}
