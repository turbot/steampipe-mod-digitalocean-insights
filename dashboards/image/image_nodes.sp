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
        'Slug', slug,
        'Created At', created_at,
        'Minimum Disk Size', min_disk_size,
        'Distribution', distribution
      ) as properties
    from
      digitalocean_image
    where
      urn = any($1);
  EOQ

  param "image_image_urns" {}
}