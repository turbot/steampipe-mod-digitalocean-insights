dashboard "digitalocean_snapshot_age_report" {

  title         = "DigitalOcean Snapshots Age Report"
  documentation = file("./dashboards/snapshot/docs/snapshot_report_age.md")

  tags = merge(local.snapshot_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.digitalocean_snapshot_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_snapshot_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_snapshot_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_snapshot_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.digitalocean_snapshot_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.digitalocean_snapshot_1_year_count
    }

  }

  table {
    column "Account ID" {
      display = "none"
    }

    column "ARN" {
      display = "none"
    }

    query = query.digitalocean_snapshot_age_table
  }

}

query "digitalocean_snapshot_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      digitalocean_snapshot
    where
      created_at > now() - '1 days' :: interval;
  EOQ
}

query "digitalocean_snapshot_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      digitalocean_snapshot
    where
      created_at between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "digitalocean_snapshot_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      digitalocean_snapshot
    where
      created_at between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "digitalocean_snapshot_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      digitalocean_snapshot
    where
      created_at between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "digitalocean_snapshot_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      digitalocean_snapshot
    where
      created_at <= now() - '1 year' :: interval;
  EOQ
}

query "digitalocean_snapshot_age_table" {
  sql = <<-EOQ
    select
      s.name as "Name",
      s.id as "ID",
      now()::date - s.created_at::date as "Age in Days",
      s.created_at as "Create Time",
      s.resource_type as "Resource Type",
      s.regions as "Region"
    from
      digitalocean_snapshot as s
    order by
      s.id;
  EOQ
}