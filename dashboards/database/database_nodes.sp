node "database_cluster" {
  category = category.database_cluster

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'URN', urn,
        'ID', id,
        'Name', name,
        'Title', title,
        'Version', version,
        'Engine', engine,
        'Region', region_slug
      ) as properties
    from
      digitalocean_database
    where
      urn = any($1);
  EOQ

  param "database_cluster_urns" {}
}