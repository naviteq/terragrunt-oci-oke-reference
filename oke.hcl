dependency "oke" {
  config_path = "../oke"
}
# We overwrite terraform block to use custom provider
generate "provider" {
  path      = "provider.auto.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      backend "s3" {}
      required_version = "~> 1.2"
      required_providers {
        oci = {
          source                = "oracle/oci"
          configuration_aliases = [oci.home]
          version               = "~> 5.30"
        }
        kubectl = {
          source  = "gavinbunney/kubectl"
          version = ">= 1.7.0"
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "~> 2"
        }
        helm = {
          source  = "hashicorp/helm"
          version = "~> 2"
        }
      }
    }
    # We don't use the AWS here, so just "mock" until we rely on AWS resources in the Module
    # TODO: Remove after https://github.com/naviteq/terraform-kubernetes-cluster-services/issues/36 fix
    provider "aws" {
      region = "us-east-1"
      skip_credentials_validation = true
      skip_requesting_account_id = true
      skip_region_validation  = true
    }
  EOF
}
# We configure k8s related providers
generate "k8s" {
  path      = "k8s.auto.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    variable "oracle_region" {}
    locals {
      ca = "${dependency.oke.outputs.cluster_ca_cert}"
    }
    provider "kubectl" {
      host                   = var.cluster.endpoint
      cluster_ca_certificate = base64decode(local.ca)
      load_config_file = false
      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["ce", "cluster", "generate-token", "--cluster-id", "${dependency.oke.outputs.cluster_id}", "--region", var.oracle_region]
        command     = "oci"
      }
    }
    provider "kubernetes" {
      host                   = var.cluster.endpoint
      config_path = null
      cluster_ca_certificate = base64decode(local.ca)
      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["ce", "cluster", "generate-token", "--cluster-id", "${dependency.oke.outputs.cluster_id}", "--region", var.oracle_region]
        command     = "oci"
      }
    }
    provider "helm" {
      kubernetes {
        host                   = var.cluster.endpoint
        config_path = null
        cluster_ca_certificate = base64decode(local.ca)
        exec {
          api_version = "client.authentication.k8s.io/v1beta1"
          args        = ["ce", "cluster", "generate-token", "--cluster-id", "${dependency.oke.outputs.cluster_id}", "--region", var.oracle_region]
          command     = "oci"
        }
      }
    }
  EOF
}
