locals {
  database_common_tags = {
    service = "DigitalOcean/Database"
  }
}

category "database_cluster" {
  title = "Database Cluster"
  color = local.database_color
  href  = "/digitalocean_insights.dashboard.database_cluster_detail?input.database_cluster_urn={{.properties.'URN' | @uri}}"
  icon  = "tenancy"
}