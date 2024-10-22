locals {
  network_common_tags = {
    service = "DigitalOcean/Network"
  }
}

category "network_firewall" {
  title = "Network Firewall"
  color = local.networking_color
  href  = "/digitalocean_insights.dashboard.network_firewall_detail?input.firewall_urn={{.properties.'URN' | @uri}}"
  icon  = "local_fire_department"
}

category "network_floating_ip" {
  title = "Network Floating IP"
  color = local.networking_color
  icon = "swipe_right_alt"
}

category "network_load_balancer" {
  title = "Network Load Balancer"
  color = local.networking_color
  icon = "mediation"
}

category "network_vpc" {
  title = "Network VPC"
  color = local.networking_color
  href  = "/digitalocean_insights.dashboard.network_vpc_detail?input.vpc_urn={{.properties.'URN' | @uri}}"
  icon = "cloud"
}
