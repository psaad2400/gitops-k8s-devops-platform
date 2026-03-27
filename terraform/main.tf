terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.5.1"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "dev" {
  name       = "devops-cluster"
  node_image = "kindest/node:v1.29.2"

  kind_config {
  kind        = "Cluster"
  api_version = "kind.x-k8s.io/v1alpha4"

  node {
    role = "control-plane"
  }

  node {
    role = "worker"
  }

  node {
    role = "worker"
  }
}
}