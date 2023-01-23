edge "droplet_droplet_to_blockstorage_volume" {
  title = "mounts"

  sql = <<-EOQ
    with volume_droplet_ids as (
      select
        jsonb_array_elements(droplet_ids) as d,
        urn
      from
        digitalocean_volume
    )
    select
      d.urn as from_id,
      v.urn as to_id
    from
      digitalocean_droplet as d,
      volume_droplet_ids as v
    where
      d.id::int = d::int
      and d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}

edge "droplet_droplet_to_network_firewall" {
  title = "firewall"

  sql = <<-EOQ
    with firewall_droplet_ids as (
      select
        jsonb_array_elements(droplet_ids) as did,
        urn
      from
        digitalocean_firewall
    )
    select
      d.urn as from_id,
      f.urn as to_id
    from
      firewall_droplet_ids as f,
      digitalocean_droplet as d
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
    with lb_droplet_ids as (
      select
        jsonb_array_elements(droplet_ids) as did,
        urn
      from
        digitalocean_load_balancer
    )
    select
      d.urn as from_id,
      l.urn as to_id
    from
      lb_droplet_ids as l,
      digitalocean_droplet as d
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
      d.urn as from_id,
      v.urn as to_id
    from
      digitalocean_droplet as d,
      digitalocean_vpc as v
    where
      v.id = d.vpc_uuid
      and d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}

edge "droplet_droplet_to_snapshot_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
    select
      d.urn as from_id,
      s.akas::text as to_id
    from
      digitalocean_droplet as d,
      jsonb_array_elements(snapshot_ids) as sid,
      digitalocean_snapshot as s
    where
      d.urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}