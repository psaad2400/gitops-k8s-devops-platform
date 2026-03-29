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

    extra_port_mappings {      # Application Service
      container_port = 30007   # NodePort inside cluster
      host_port      = 30007   # Port on your machine
      protocol       = "TCP"
    }

    extra_port_mappings {      # ArgoCD
      container_port = 30008   # NodePort inside cluster
      host_port      = 30008   # Port on your machine
      protocol       = "TCP"
    }

    extra_port_mappings {      # Grafana
      container_port = 30009   # NodePort inside cluster
      host_port      = 30009   # Port on your machine
      protocol       = "TCP"
    }
  }


  node {
    role = "worker"
  }

  node {
    role = "worker"
  }
}
}