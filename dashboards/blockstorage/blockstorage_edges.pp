edge "blockstorage_volume_to_network_floating_ip" {
  title = "floating ip"

  sql = <<-EOQ
    select
      v.urn as from_id,
      f.urn as to_id
    from
      digitalocean_floating_ip as f,
      jsonb_array_elements_text(droplet -> 'volume_ids') as vid,
      digitalocean_volume as v
    where
      v.id = vid::text
      and v.urn = any($1);
  EOQ

  param "blockstorage_volume_urns" {}
}

edge "blockstorage_volume_to_snapshot_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
    select
      v.urn as from_id,
      s.id as to_id
    from
      digitalocean_volume as v,
      digitalocean_snapshot as s
    where
      s.resource_id = v.id
      and s.resource_type = 'volume'
      and v.urn = any($1);
  EOQ

  param "blockstorage_volume_urns" {}
}
