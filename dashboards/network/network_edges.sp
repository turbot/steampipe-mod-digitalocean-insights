edge "network_firewall_to_droplet_droplet" {
  title = "droplet"

  sql = <<-EOQ
    with firewall_droplet_ids as (
      select
        jsonb_array_elements(droplet_ids) as did,
        urn
      from
        digitalocean_firewall
    )
    select
      f.urn as from_id,
      d.urn as to_id
    from
      firewall_droplet_ids as f,
      digitalocean_droplet as d
    where
      d.id::text = did::text
      and f.urn = any($1);
  EOQ

  param "network_firewall_urns" {}
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
    select
      v.urn as from_id,
      d.urn as to_id
    from
      digitalocean_droplet as d,
      digitalocean_vpc as v
    where
      v.id = d.vpc_uuid
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

edge "network_vpc_to_network_floating_ip" {
  title = "floating ip"

  sql = <<-EOQ
    select
      d.urn as from_id,
      f.urn as to_id
    from
      digitalocean_vpc as v,
      digitalocean_droplet as d,
      digitalocean_floating_ip as f
    where
      v.id = droplet ->> 'vpc_uuid'
      and d.id = f.droplet_id
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