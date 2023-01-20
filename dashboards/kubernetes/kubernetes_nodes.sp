node "kubernetes_cluster" {
  category = category.kubernetes_cluster

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'URN', urn,
        'Name', name,
        'Title', title,
        'Cluster Subnet', cluster_subnet,
        'Service Subnet', service_subnet,
        'Region', region_slug
      ) as properties
    from
      digitalocean_kubernetes_cluster
    where
      urn = any($1);
  EOQ

  param "kubernetes_cluster_urns" {}
}

node "kubernetes_node_pool" {
  category = category.kubernetes_node_pool

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'ID', id,
        'URN', urn,
        'Created At', created_at,
        'Memory', memory,
        'Virtual CPU Count', vcpus,
        'Region', region ->> 'name'
      ) as properties
    from
      digitalocean_droplet
    where
      tags_src is not null
      and urn = any($1);
  EOQ

  param "kubernetes_node_pool_urns" {}
}