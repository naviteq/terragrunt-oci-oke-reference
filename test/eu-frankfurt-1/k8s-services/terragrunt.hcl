# Includes
include "oracle" {
  path           = find_in_parent_folders("oracle.hcl")
  merge_strategy = "deep"
  expose         = true
}
include "oke" {
  path           = find_in_parent_folders("oke.hcl")
  merge_strategy = "deep"
}
terraform {
  source = "tfr://terraform.naviteq.io/naviteq/cluster-services/kubernetes?version=0.9.0"
}
inputs = {
  # Naviteq module specifics
  oracle_region            = include.oracle.locals.region
  default_enabled_services = ["metrics-server", "kube-prometheus-stack"]
  disabled_services        = ["argo-cd"]
  enabled_services         = ["nginx-controller", "cluster-autoscaler"]
  cluster = {
    name     = dependency.oke.outputs.cluster_id
    endpoint = "https://${dependency.oke.outputs.cluster_endpoints.public_endpoint}"
  }
  values_content_override = {
    nginx-controller = templatefile("nginx-controller.yaml", {
      nsg = dependency.oke.outputs.pub_lb_nsg_id
    })
    cluster-autoscaler = templatefile("cluster-autoscaler.yaml", {
      nodes = dependency.oke.outputs.worker_pools
    })
  }
}
dependency "oke" {
  config_path = "../oke"
}
