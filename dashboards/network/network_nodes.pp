node "network_firewall" {
  category = category.network_firewall

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'URN', urn,
        'Name', name,
        'Title', title
      ) as properties
    from
      digitalocean_firewall
    where
      urn = any($1);
  EOQ

  param "network_firewall_urns" {}
}

node "network_floating_ip" {
  category = category.network_floating_ip

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'URN', urn,
        'Public IP', ip,
        'Region', region -> 'name'
      ) as properties
    from
      digitalocean_floating_ip
    where
      urn = any($1);
  EOQ

  param "network_floating_ip_urns" {}
}

node "network_load_balancer" {
  category = category.network_load_balancer

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'ID', id,
        'URN', urn,
        'Created At', created_at,
        'IP', ip,
        'Region', region_name
      ) as properties
    from
      digitalocean_load_balancer
    where
      urn = any($1);
  EOQ

  param "network_load_balancer_urns" {}
}

node "network_vpc" {
  category = category.network_vpc

  sql = <<-EOQ
    select
      urn as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'ID', id,
        'URN', urn,
        'Created At', created_at,
        'IP Range', ip_range,
        'Region', region_slug
      ) as properties
    from
      digitalocean_vpc
    where
      urn = any($1);
  EOQ

  param "network_vpc_urns" {}
}

