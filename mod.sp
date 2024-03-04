mod "digitalocean_insights" {
  # hub metadata
  title         = "DigitalOcean Insights"
  description   = "Create dashboards and reports for your DigitalOcean resources using Powerpipe."
  color         = "#008bcf"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/digitalocean-insights.svg"
  categories    = ["digitalocean", "dashboard", "public cloud"]

  opengraph {
    title       = "Powerpipe Mod for DigitalOcean Insights"
    description = "Create dashboards and reports for your DigitalOcean resources using Powerpipe."
    image       = "/images/mods/turbot/digitalocean-insights-social-graphic.png"
  }

  require {
    plugin "digitalocean" {
      min_version = "0.11.0"
    }
  }
}
