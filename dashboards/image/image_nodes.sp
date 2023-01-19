node "image_image" {
  category = category.image_image

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'ID', id,
        'URN', urn,
        'Created At', created_at,
        'Minimum Disk Size', min_disk_size,
        'Region', regions
      ) as properties
    from
      digitalocean_image
    where
      urn = any($1);
  EOQ

  param "image_image_urns" {}
}