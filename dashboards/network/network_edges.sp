edge "network_firewall_to_droplet_droplet" {
  title = "droplet"

  sql = <<-EOQ
    select
      f.urn as from_id,
      d.urn as to_id
    from
      digitalocean_droplet as d,
      digitalocean_vpc as v,
      digitalocean_firewall as f,
      jsonb_array_elements(droplet_ids) as did
    where
      did::text = d.id::text
      and v.id = d.vpc_uuid
      and f.urn = any($1);
  EOQ

  param "network_firewall_urns" {}
}

edge "network_firewall_to_network_vpc" {
  title = "vpc"

  sql = <<-EOQ
    select
      f.urn as from_id,
      v.urn as to_id
    from
      digitalocean_droplet as d,
      digitalocean_vpc as v,
      digitalocean_firewall as f,
      jsonb_array_elements(droplet_ids) as did
    where
      did::text = d.id::text
      and v.id = d.vpc_uuid
      and d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}

edge "network_vpc_to_database_cluster" {
  title = "database cluster"

  sql = <<-EOQ
    select
      v.urn as from_id,
      d.urn as to_id
    from
      digitalocean_database as d,
      digitalocean_vpc as v
    where
      v.id = d.private_network_uuid
      and v.urn = any($1)
  EOQ

  param "network_vpc_urns" {}
}

edge "network_vpc_to_droplet_droplet" {
  title = "droplet"

  sql = <<-EOQ
    with firewall_droplet_ids as (
      select
        d as droplet_id
      from
        digitalocean_firewall as f,
        jsonb_array_elements_text(droplet_ids) as d
    )
    select
      v.urn as from_id,
      d.urn as to_id
    from
      digitalocean_droplet as d,
      digitalocean_vpc as v
    where
      d.id::text not in(select droplet_id from firewall_droplet_ids)
      and v.id = d.vpc_uuid
      and v.urn = any($1);
  EOQ

  param "network_vpc_urns" {}
}

edge "network_vpc_to_kubernetes_cluster" {
  title = "kubernetes cluster"

  sql = <<-EOQ
    select
      v.urn as from_id,
      k.urn as to_id
    from
      digitalocean_vpc as v,
      digitalocean_kubernetes_cluster as k
    where
      v.id = k.vpc_uuid
      and v.urn = any($1);
  EOQ

  param "network_vpc_urns" {}
}

edge "network_vpc_to_network_firewall" {
  title = "firewall"

  sql = <<-EOQ
    select
      v.urn as from_id,
      f.urn as to_id
    from
      digitalocean_firewall as f,
      jsonb_array_elements_text(droplet_ids) as did,
      digitalocean_droplet as d,
      digitalocean_vpc as v
    where
      d.vpc_uuid = v.id
      and did = d.id::text
      and v.urn = any($1);
  EOQ

  param "network_vpc_urns" {}
}

edge "network_vpc_to_network_load_balancer" {
  title = "load balancer"

  sql = <<-EOQ
    select
      v.urn as from_id,
      l.urn as to_id
    from
      digitalocean_load_balancer as l,
      digitalocean_vpc as v
    where
      v.id = l.vpc_uuid
      and v.urn = any($1);
  EOQ

  param "network_vpc_urns" {}
}