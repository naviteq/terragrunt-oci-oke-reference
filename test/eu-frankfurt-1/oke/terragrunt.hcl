include "oracle" {
  path           = find_in_parent_folders("oracle.hcl")
  merge_strategy = "deep"
  expose         = true
}
include "oke-module" {
  path = find_in_parent_folders("oke-module.hcl")
}
terraform {
  source = "tfr://registry.terraform.io/oracle-terraform-modules/oke/oci?version=5.1.2"
}
inputs = {
  compartment_id = dependency.compartment.outputs.compartment_id
  cni_type       = "npn" # Native Pod Networking
  # Network
  vcn_id             = dependency.vcn.outputs.vcn_id
  ig_route_table_id  = dependency.subnets.outputs.all_attributes.public.route_table_id
  nat_route_table_id = dependency.subnets.outputs.all_attributes.private.route_table_id
}
dependency "compartment" {
  config_path = "../compartment"
}
dependency "vcn" {
  config_path = "../vcn"
}
dependency "subnets" {
  config_path = "../subnets"
}
# As far as we want to manage NSGs using the cloud controller we need to define additional policies
generate "nsg_permissions" {
  path      = "nsg-permissions.auto.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    resource "oci_identity_policy" "nsg_permissions" {
      compartment_id = local.compartment_id
      description = "Policies (Additional) for OKE Terraform state $${local.state_id}"
      name = "oke-cluster-$${local.state_id}-additional"
      statements = [ for s in ["vcns", "virtual-network-family"]: "Allow any-user to manage $${s} in compartment id $${local.compartment_id} where request.principal.type = 'cluster'"]
    }
EOF
}
