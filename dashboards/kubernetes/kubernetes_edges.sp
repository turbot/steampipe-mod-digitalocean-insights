edge "kubernetes_cluster_to_database_cluster" {
  title = "database cluster"

  sql = <<-EOQ
    select
      k.urn as from_id,
      d.urn as to_id
    from
      digitalocean_database as d,
      jsonb_array_elements(firewall_rules) as fr,
      digitalocean_kubernetes_cluster as k
    where
      fr ->> 'type' = 'k8s'
      and k.id::text = fr ->> 'value'
      and k.urn = any($1);
  EOQ

  param "kubernetes_cluster_urns" {}
}

edge "kubernetes_cluster_to_kubernetes_cluster_node" {
  title = "node"

  sql = <<-EOQ
    select
      k.urn as from_id,
      d.urn as to_id
    from
      digitalocean_kubernetes_cluster as k,
      jsonb_array_elements(k.node_pools) as node_pool,
      jsonb_array_elements(node_pool -> 'nodes') as node,
      digitalocean_droplet as d
    where
      d.id::text = node ->> 'droplet_id'
      and k.urn = any($1);
  EOQ

  param "kubernetes_cluster_urns" {}
}

edge "kubernetes_cluster_to_network_vpc" {
  title = "vpc"

  sql = <<-EOQ
    select
      k.urn as from_id,
      v.urn as to_id
    from
      digitalocean_kubernetes_cluster as k,
      digitalocean_vpc as v
    where
      v.id = k.vpc_uuid
      and k.urn = any($1);
  EOQ

  param "kubernetes_cluster_urns" {}
}