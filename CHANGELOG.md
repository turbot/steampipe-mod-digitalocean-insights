## v1.0.0 [2024-10-22]

This mod now requires [Powerpipe](https://powerpipe.io). [Steampipe](https://steampipe.io) users should check the [migration guide](https://powerpipe.io/blog/migrating-from-steampipe).

## v0.6 [2024-03-06]

_Powerpipe_

[Powerpipe](https://powerpipe.io) is now the preferred way to run this mod!  [Migrating from Steampipe →](https://powerpipe.io/blog/migrating-from-steampipe)

All v0.x versions of this mod will work in both Steampipe and Powerpipe, but v1.0.0 onwards will be in Powerpipe format only.

_Enhancements_

- Focus documentation on Powerpipe commands.
- Show how to combine Powerpipe mods with Steampipe plugins.

## v0.5 [2023-11-03]

_Breaking changes_

- Updated the plugin dependency section of the mod to use `min_version` instead of `version`. ([#43](https://github.com/turbot/steampipe-mod-digitalocean-insights/pull/43))

_Bug fixes_

- Fixed dashboard localhost URLs in README and index doc. ([#39](https://github.com/turbot/steampipe-mod-digitalocean-insights/pull/39))

## v0.4 [2023-01-30]

_Bug fixes_

- Fix the broken image reference in `docs/index.md` file to use the correct image name in `docs/images` folder.

## v0.3 [2023-01-30]

_Dependencies_

- Steampipe `v0.18.0` or higher is now required ([#35](https://github.com/turbot/steampipe-mod-digitalocean-insights/pull/35))
- DigitalOcean plugin `v0.11.0` or higher is now required. ([#34](https://github.com/turbot/steampipe-mod-digitalocean-insights/pull/34))

_What's new?_

- Added resource relationship graphs across all the detail dashboards to highlight the relationship the resource shares with other resources. ([#34](https://github.com/turbot/steampipe-mod-digitalocean-insights/pull/34))

## v0.2 [2022-05-09]

_Enhancements_

- Updated docs/index.md and README to the latest format. ([#28](https://github.com/turbot/steampipe-mod-digitalocean-insights/pull/28))

## v0.1 [2022-04-22]

_What's new?_

New dashboards, reports, and details for the following services:
- Block Storage
- Database
- Droplet
- Firewall
- Kubernetes
- Snapshot
