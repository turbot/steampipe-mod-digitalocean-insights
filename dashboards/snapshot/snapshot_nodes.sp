node "snapshot_snapshot" {
  category = category.snapshot_snapshot

  sql = <<-EOQ
    select
      id as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'ID', id,
        'Created At', created_at,
        'Minimum Disk Size', min_disk_size,
        'Resource Type', resource_type,
        'Region', regions,
        'URN', id
      ) as properties
    from
      digitalocean_snapshot
    where
      id = any($1);
  EOQ

  param "snapshot_snapshot_urns" {}
}

