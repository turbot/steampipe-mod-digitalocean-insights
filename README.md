# DigitalOcean Insights Mod for Powerpipe

A DigitalOcean dashboarding tool that can be used to view dashboards and reports across all of your DigitalOcean projects.

![image](https://raw.githubusercontent.com/turbot/steampipe-mod-digitalocean-insights/main/docs/images/digitalocean_droplet_dashboard.png)

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- Are there any publicly accessible resources?
- What are the relationships between closely connected resources like droplets, volumes, network firewalls, load balancers and VPCs?

Dashboards are available for BlockStorage, Database, Droplet, Firewall, Kubernetes and Snapshot services.

## Documentation

- **[Dashboards →](https://hub.powerpipe.io/mods/turbot/digitalocean_insights/dashboards)**

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- Are there any publicly accessible resources?
- What are the relationships between closely connected resources like droplets, volumes, network firewalls, load balancers and VPCs?

Dashboards are available for BlockStorage, Database, Droplet, Firewall, Kubernetes and Snapshot services.

## Getting Started

### Installation

Install Powerpipe (https://powerpipe.io/downloads), or use Brew:

```sh
brew install turbot/tap/powerpipe
```

This mod also requires [Steampipe](https://steampipe.io) with the [DigitalOcean plugin](https://hub.steampipe.io/plugins/turbot/digitalocean) as the data source. Install Steampipe (https://steampipe.io/downloads), or use Brew:

```sh
brew install turbot/tap/steampipe
steampipe plugin install digitalocean
```

Finally, install the mod:

```sh
mkdir dashboards
cd dashboards
powerpipe mod init
powerpipe mod install github.com/turbot/steampipe-mod-digitalocean-insights
```

### Browsing Dashboards

Start Steampipe as the data source:

```sh
steampipe service start
```

Start the dashboard server:

```sh
powerpipe server
```

Browse and view your dashboards at **http://localhost:9033**.

## Open Source & Contributing

This repository is published under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0). Please see our [code of conduct](https://github.com/turbot/.github/blob/main/CODE_OF_CONDUCT.md). We look forward to collaborating with you!

[Steampipe](https://steampipe.io) and [Powerpipe](https://powerpipe.io) are products produced from this open source software, exclusively by [Turbot HQ, Inc](https://turbot.com). They are distributed under our commercial terms. Others are allowed to make their own distribution of the software, but cannot use any of the Turbot trademarks, cloud services, etc. You can learn more in our [Open Source FAQ](https://turbot.com/open-source).

## Get Involved

**[Join #powerpipe on Slack →](https://turbot.com/community/join)**

Want to help but don't know where to start? Pick up one of the `help wanted` issues:

- [Powerpipe](https://github.com/turbot/powerpipe/labels/help%20wanted)
- [DigitalOcean Insights Mod](https://github.com/turbot/steampipe-mod-digitalocean-insights/labels/help%20wanted)
