edge "blockstorage_volume_to_snapshot_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
    select
      v.urn as from_id,
      s.akas::text as to_id
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