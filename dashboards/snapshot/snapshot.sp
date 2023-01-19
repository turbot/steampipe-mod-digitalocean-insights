locals {
  snapshot_common_tags = {
    service = "DigitalOcean/Snapshot"
  }
}

category "snapshot_snapshot" {
  title = "Snapshot"
  color = local.compute_color
  # href  = "/digitalocean_insights.dashboard.snapshot_detail?input.droplet_urn={{.properties.'ID' | @uri}}"
  icon  = "add_a_photo"
}