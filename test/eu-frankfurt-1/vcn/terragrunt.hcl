include "oracle" {
  path           = find_in_parent_folders("oracle.hcl")
  merge_strategy = "deep"
}
terraform {
  source = "tfr://registry.terraform.io/oracle-terraform-modules/vcn/oci?version=3.6.0"
}
inputs = {
  compartment_id = dependency.compartment.outputs.compartment_id
}
dependency "compartment" {
  config_path = "../compartment"
}
