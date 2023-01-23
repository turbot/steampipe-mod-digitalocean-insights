edge "snapshot_snapshot_to_droplet_droplet" {
  title = "droplet"

  sql = <<-EOQ
    with droplet_images as (
      select
        image->>'id' as iid,
        urn
      from
        digitalocean_droplet
    )
    select
      s.akas::text as from_id,
      d.urn as to_id
    from
      digitalocean_image as i,
      digitalocean_snapshot as s,
      droplet_images as d
    where
      i.id::text = iid
      and i.id::text = s.id
      and s.akas::text = any($1);
  EOQ

  param "snapshot_snapshot_urns" {}
}

# edge "snapshot_snapshot_to_blockstorage_volume" {
#   title = "droplet"

#   sql = <<-EOQ
#     with droplet_images as (
#       select
#         image->>'id' as iid,
#         urn
#       from
#         digitalocean_droplet
#     )
#     select
#       s.akas::text as from_id,
#       d.urn as to_id
#     from
#       digitalocean_image as i,
#       digitalocean_snapshot as s,
#       droplet_images as d
#     where
#       i.id::text = iid
#       and i.id::text = s.id
#       and s.akas::text = any($1);
#   EOQ

#   param "snapshot_snapshot_urns" {}
# }