include "oracle" {
  path           = find_in_parent_folders("oracle.hcl")
  merge_strategy = "deep"
}
terraform {
  source = "tfr://registry.terraform.io/oracle-terraform-modules/vcn/oci//modules/subnet?version=3.6.0"
}
inputs = {
  compartment_id = dependency.compartment.outputs.compartment_id
  vcn_id         = dependency.vcn.outputs.vcn_id
  nat_route_id   = dependency.vcn.outputs.nat_route_id
  ig_route_id    = dependency.vcn.outputs.ig_route_id
  subnets = {
    public = {
      cidr_block = cidrsubnet(include.root.inputs.vcn_cidrs[0], 8, 250)
      type       = "public"
    }
    private = {
      cidr_block = cidrsubnet(include.root.inputs.vcn_cidrs[0], 8, 251)
      type       = "private"
    }
  }
}
dependency "compartment" {
  config_path = "../compartment"
}
dependency "vcn" {
  config_path = "../vcn"
}
