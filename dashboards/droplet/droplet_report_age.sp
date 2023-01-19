dashboard "digitalocean_droplet_age_report" {

  title         = "DigitalOcean Droplet Age Report"
  documentation = file("./dashboards/droplet/docs/droplet_report_age.md")

  tags = merge(local.droplet_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.digitalocean_droplet_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_droplet_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_droplet_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_droplet_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.digitalocean_droplet_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.digitalocean_droplet_1_year_count
    }

  }

  table {

    column "URN" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.droplet_detail.url_path}?input.droplet_urn={{.'URN' | @uri}}"
    }

    query = query.digitalocean_droplet_age_table
  }

}

query "digitalocean_droplet_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      digitalocean_droplet
    where
      created_at > now() - '1 days' :: interval;
  EOQ
}

query "digitalocean_droplet_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      digitalocean_droplet
    where
      created_at between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "digitalocean_droplet_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      digitalocean_droplet
    where
      created_at between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "digitalocean_droplet_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      digitalocean_droplet
    where
      created_at between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "digitalocean_droplet_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      digitalocean_droplet
    where
      created_at <= now() - '1 year' :: interval;
  EOQ
}

query "digitalocean_droplet_age_table" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      now()::date - created_at::date as "Age in Days",
      created_at as "Create Time",
      status as "Status",
      region ->> 'name' as "Region",
      urn as "URN"
    from
      digitalocean_droplet
    order by
      name;
  EOQ
}
