node "snapshot_snapshot" {
  category = category.snapshot_snapshot

  sql = <<-EOQ
    select
      akas::text as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'ID', id,
        'Created At', created_at,
        'Minimum Disk Size', min_disk_size,
        'Resource Type', resource_type,
        'Region', regions
      ) as properties
    from
      digitalocean_snapshot
    where
      akas::text = any($1);
  EOQ

  param "snapshot_snapshot_urns" {}
}

