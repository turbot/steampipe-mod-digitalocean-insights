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

edge "kubernetes_cluster_to_kubernetes_node_pool" {
  title = "pool"

  sql = <<-EOQ
    select
      c.urn as from_id,
      p.urn as to_id
    from
      digitalocean_kubernetes_node_pool as p,
      digitalocean_kubernetes_cluster as c
    where
      p.cluster_id = c.id
      and c.urn = any($1);
  EOQ

  param "kubernetes_cluster_urns" {}
}

edge "kubernetes_node_pool_to_kubernetes_cluster_node" {
  title = "node"

  sql = <<-EOQ
    select
      p.urn as from_id,
      d.urn as to_id
    from
      digitalocean_kubernetes_node_pool as p,
      jsonb_array_elements(nodes) as n,
      digitalocean_droplet as d
    where
      d.id::text = n ->> 'droplet_id'
      and p.urn = any($1);
  EOQ

  param "kubernetes_node_pool_urns" {}
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