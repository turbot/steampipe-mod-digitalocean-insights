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

node "kubernetes_cluster_node" {
  category = category.kubernetes_cluster_node

  sql = <<-EOQ
    select
      d.urn as id,
      d.title as title,
      jsonb_build_object(
        'Name', d.name,
        'ID', d.id,
        'URN', d.urn,
        'Created At', d.created_at,
        'Memory', d.memory,
        'Virtual CPU Count', d.vcpus,
        'Region', d.region ->> 'name'
      ) as properties
    from
      digitalocean_droplet as d,
      digitalocean_kubernetes_cluster as k,
      jsonb_array_elements(k.node_pools) as node_pool,
      jsonb_array_elements(node_pool -> 'nodes') as node
    where
      d.id::text = node ->> 'droplet_id'
      and d.urn = any($1);
  EOQ

  param "kubernetes_cluster_node_urns" {}
}