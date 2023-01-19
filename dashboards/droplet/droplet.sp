locals {
  droplet_common_tags = {
    service = "DigitalOcean/Droplet"
  }
}

category "droplet_droplet" {
  title = "Droplet"
  color = local.compute_color
  href  = "/digitalocean_insights.dashboard.droplet_detail?input.droplet_urn={{.properties.'ID' | @uri}}"
  icon  = "memory"
}