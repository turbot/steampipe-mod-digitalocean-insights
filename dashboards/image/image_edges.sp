edge "image_image_to_droplet_droplet" {
  title = "droplet"

  sql = <<-EOQ
    select
      i.urn as from_id,
      d.urn as to_id
    from
      digitalocean_image as i,
      digitalocean_droplet as d
    where
      i.id::text = d.image->>'id'
      and i.urn = any($1);
  EOQ

  param "image_image_urns" {}
}