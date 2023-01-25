edge "droplet_droplet_to_blockstorage_volume" {
  title = "mounts"

  sql = <<-EOQ
    select
      d.urn as from_id,
      v.urn as to_id
    from
      digitalocean_droplet as d,
      digitalocean_volume as v,
      jsonb_array_elements(droplet_ids) as did
    where
      d.id::int = did::int
      and d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}

edge "droplet_droplet_to_database_cluster" {
  title = "database cluster"

  sql = <<-EOQ
    select
      d.urn as from_id,
      db.urn as to_id
    from
      digitalocean_database as db,
      jsonb_array_elements(firewall_rules) as fr,
      digitalocean_droplet as d
    where
      fr ->> 'type' = 'droplet'
      and d.id::text = fr ->> 'value'
      and d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}

edge "droplet_droplet_to_network_firewall" {
  title = "firewall"

  sql = <<-EOQ
    select
      d.urn as from_id,
      f.urn as to_id
    from
      digitalocean_droplet as d,
      digitalocean_firewall as f,
      jsonb_array_elements(droplet_ids) as did
    where
      d.id::text = did::text
      and d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}

edge "droplet_droplet_to_network_floating_ip" {
  title = "floating ip"

  sql = <<-EOQ
    select
      d.urn as from_id,
      f.urn as to_id
    from
      digitalocean_floating_ip as f,
      digitalocean_droplet as d
    where
      d.id = f.droplet_id
      and d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}

edge "droplet_droplet_to_network_load_balancer" {
  title = "load balancer"

  sql = <<-EOQ
    select
      d.urn as from_id,
      l.urn as to_id
    from
      digitalocean_droplet as d,
      digitalocean_load_balancer as l,
      jsonb_array_elements(droplet_ids) as did
    where
      d.id::text = did::text
      and d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}

edge "droplet_droplet_to_network_vpc" {
  title = "vpc"

  sql = <<-EOQ
    select
      coalesce(f.urn, d.urn) as from_id,
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

edge "droplet_droplet_to_snapshot_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
    select
      d.urn as from_id,
      s.id as to_id
    from
      digitalocean_droplet as d,
      jsonb_array_elements(snapshot_ids) as sid,
      digitalocean_snapshot as s
    where
      d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}
