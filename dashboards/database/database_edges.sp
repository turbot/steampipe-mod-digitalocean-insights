edge "database_cluster_to_network_vpc" {
  title = "vpc"

  sql = <<-EOQ
    select
      d.urn as from_id,
      v.urn as to_id
    from
      digitalocean_database as d,
      digitalocean_vpc as v
    where
      v.id = d.private_network_uuid
      and d.urn = any($1);
  EOQ

  param "database_cluster_urns" {}
}