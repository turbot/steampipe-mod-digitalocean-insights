node "droplet_droplet" {
  category = category.droplet_droplet

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'ID', id,
        'URN', urn,
        'Created At', created_at,
        'Memory', memory,
        'Virtual CPU Count', vcpus,
        'Region', region ->> 'name'
      ) as properties
    from
      digitalocean_droplet
    where
      urn = any($1);
  EOQ

  param "droplet_droplet_urns" {}
}

