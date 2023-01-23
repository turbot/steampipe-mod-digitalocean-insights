locals {
  kubernetes_common_tags = {
    service = "DigitalOcean/Kubernetes"
  }
}

category "kubernetes_cluster" {
  title = "Kubernetes Cluster"
  color = local.containers_color
  href  = "/digitalocean_insights.dashboard.kubernetes_detail?input.cluster_urn={{.properties.'URN' | @uri}}"
  icon  = "view_in_ar"
}

category "kubernetes_cluster_node" {
  title = "Kubernetes Cluster Node"
  color = local.containers_color
  icon  = "device_hub"
}