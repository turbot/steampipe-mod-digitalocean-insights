edge "snapshot_snapshot_to_droplet_droplet" {
  title = "droplet"

  sql = <<-EOQ
    select
      s.id as from_id,
      d.urn as to_id
    from
      digitalocean_image as i,
      digitalocean_snapshot as s,
      digitalocean_droplet as d
    where
      i.id::text = image->>'id'
      and i.id::text = s.id
      and s.id = any($1);
  EOQ

  param "snapshot_snapshot_urns" {}
}

edge "snapshot_snapshot_to_network_floating_ip" {
  title = "floating ip"

  sql = <<-EOQ
    select
      s.id as from_id,
      f.urn as to_id
    from
      digitalocean_floating_ip as f,
      jsonb_array_elements(droplet -> 'snapshot_ids') as sid,
      digitalocean_snapshot as s
    where
      s.id = sid::text
      and s.id = any($1);
  EOQ

  param "snapshot_snapshot_urns" {}
}
