---
repository: "https://github.com/turbot/steampipe-mod-digitalocean-insights"
---

# DigitalOcean Insights Mod

Create dashboards and reports for your DigitalOcean resources using Steampipe.

<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-digitalocean-insights/main/docs/images/digitalocean_blockstorage_volume_age_report.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-digitalocean-insights/main/docs/images/digitalocean_droplet_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-digitalocean-insights/main/docs/images/digitalocean_firewall_detail.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-digitalocean-insights/main/docs/images/digitalocean_kubernetes_dashboard.png" width="50%" type="thumbnail"/>

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- Are there any publicly accessible resources?
- Is encryption enabled and what keys are used for encryption?

Dashboards are available for BlockStorage, Database, Droplet, Firewall, Kubernetes and Snapshot services.

## References

[DigitalOcean](https://www.digitalocean.com/) provides on-demand cloud computing platforms and APIs to authenticated customers on a metered pay-as-you-go basis.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration, and `dashboards` that organize and display key pieces of information.

## Documentation

- **[Dashboards →](https://hub.steampipe.io/mods/turbot/digitalocean_insights/dashboards)**

## Getting started

### Installation

1) Install the DigitalOcean plugin:

```shell
steampipe plugin install digitalocean
```

2) Clone this repo:

```sh
git clone https://github.com/turbot/steampipe-mod-digitalocean-insights.git
cd steampipe-mod-digitalocean-insights
```

### Usage

Start your dashboard server to get started:

```shell
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at https://localhost:9194.

From here, you can view all of your dashboards and reports.

### Credentials

This mod uses the credentials configured in the [Steampipe DigitalOcean plugin](https://hub.steampipe.io/plugins/turbot/digitalocean).

## Get involved

* Contribute: [GitHub Repo](https://github.com/turbot/steampipe-mod-digitalocean-insights)
* Community: [Slack Channel](https://steampipe.io/community/join)
