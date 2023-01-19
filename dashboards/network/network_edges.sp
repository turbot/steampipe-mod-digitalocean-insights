edge "network_firewall_to_droplet_droplet" {
  title = "droplet"

  sql = <<-EOQ
    with firewall_droplet_ids as (
      select
        jsonb_array_elements(droplet_ids) as did,
        urn
      from
        digitalocean_firewall
    )
    select
      f.urn as from_id,
      d.urn as to_id
    from
      firewall_droplet_ids as f,
      digitalocean_droplet as d
    where
      d.id::text = did::text
      and f.urn = any($1);
  EOQ

  param "network_firewall_urns" {}
}