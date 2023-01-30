mod "digitalocean_insights" {
  # hub metadata
  title         = "DigitalOcean Insights"
  description   = "Create dashboards and reports for your DigitalOcean resources using Steampipe."
  color         = "#008bcf"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/digitalocean-insights.svg"
  categories    = ["digitalocean", "dashboard", "public cloud"]

  opengraph {
    title       = "Steampipe Mod for DigitalOcean Insights"
    description = "Create dashboards and reports for your DigitalOcean resources using Steampipe."
    image       = "/images/mods/turbot/digitalocean-insights-social-graphic.png"
  }

  require {
    steampipe = "0.18.0"
    plugin "digitalocean" {
      version = "0.11.0"
    }
  }
}
