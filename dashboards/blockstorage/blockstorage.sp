locals {
  blockstorage_volume_common_tags = {
    service = "DigitalOcean/BlockStorage"
  }
}

category "blockstorage_volume" {
  title = "Blockstorage Volume"
  color = local.compute_color
  href  = "/digitalocean_insights.dashboard.blockstorage_volume_detail?input.volume_urn={{.properties.'ID' | @uri}}"
  icon  = "hard_drive"
}