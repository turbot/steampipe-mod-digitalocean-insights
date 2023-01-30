node "blockstorage_volume" {
  category = category.blockstorage_volume

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'ID', id,
        'URN', urn,
        'Created At', created_at,
        'Size in GiB', size_gigabytes,
        'Filesysten Type', filesystem_type,
        'Region', region_name
      ) as properties
    from
      digitalocean_volume
    where
      urn = any($1);
  EOQ

  param "blockstorage_volume_urns" {}
}