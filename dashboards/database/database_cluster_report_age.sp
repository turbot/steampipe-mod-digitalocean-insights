dashboard "database_cluster_age_report" {

  title         = "DigitalOcean Database Cluster Age Report"
  documentation = file("./dashboards/database/docs/database_cluster_report_age.md")

  tags = merge(local.database_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.database_cluster_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.database_cluster_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.database_cluster_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.database_cluster_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.database_cluster_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.database_cluster_1_year_count
    }

  }

  table {

    column "URN" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.database_cluster_detail.url_path}?input.cluster_urn={{.URN | @uri}}"
    }

    query = query.database_cluster_age_table
  }

}

query "database_cluster_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      digitalocean_database
    where
      created_at > now() - '1 days' :: interval;
  EOQ
}

query "database_cluster_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      digitalocean_database
    where
      created_at between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "database_cluster_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      digitalocean_database
    where
      created_at between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "database_cluster_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      digitalocean_database
    where
      created_at between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "database_cluster_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      digitalocean_database
    where
      created_at <= now() - '1 year' :: interval;
  EOQ
}

query "database_cluster_age_table" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      now()::date - created_at::date as "Age in Days",
      created_at as "Create Time",
      status as "Status",
      region_slug as "Region",
      urn as "URN"
    from
      digitalocean_database
    order by
      name;
  EOQ
}