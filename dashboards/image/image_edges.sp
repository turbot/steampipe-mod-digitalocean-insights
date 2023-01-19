edge "image_image_to_droplet_droplet" {
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
      i.urn as from_id,
      d.urn as to_id
    from
      digitalocean_image as i,
      droplet_images as d
    where
      i.public = true
      and i.id::text = iid
      and i.urn = any($1);
  EOQ

  param "image_image_urns" {}
}