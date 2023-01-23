dashboard "snapshot_age_report" {

  title         = "DigitalOcean Snapshots Age Report"
  documentation = file("./dashboards/snapshot/docs/snapshot_report_age.md")

  tags = merge(local.snapshot_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.snapshot_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.snapshot_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.snapshot_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.snapshot_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.snapshot_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.snapshot_1_year_count
    }

  }

  table {

    column "URN" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.snapshot_detail.url_path}?input.snapshot_urn={{.'URN' | @uri}}"
    }

    query = query.snapshot_age_table
  }

}

query "snapshot_24_hours_count" {
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

query "snapshot_30_days_count" {
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

query "snapshot_30_90_days_count" {
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

query "snapshot_90_365_days_count" {
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

query "snapshot_1_year_count" {
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

query "snapshot_age_table" {
  sql = <<-EOQ
    select
      s.name as "Name",
      s.id as "ID",
      now()::date - s.created_at::date as "Age in Days",
      s.created_at as "Create Time",
      s.regions as "Regions"
    from
      digitalocean_snapshot as s
    order by
      s.name;
  EOQ
}