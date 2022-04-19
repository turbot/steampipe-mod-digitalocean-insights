dashboard "digitalocean_block_storage_volume_age_report" {

  title         = "DigitalOcean Block Storage Volume Age Report"
  documentation = file("./dashboards/block_storage_volume/docs/block_storage_volume_report_age.md")

  tags = merge(local.block_storage_volume_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.digitalocean_volume_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_volume_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_volume_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_volume_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.digitalocean_volume_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.digitalocean_volume_1_year_count
    }

  }

  table {

    column "URN" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.digitalocean_block_storage_volume_detail.url_path}?input.volume_urn={{.URN | @uri}}"
    }

    query = query.digitalocean_volume_age_table
  }

}

query "digitalocean_volume_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      digitalocean_volume
    where
      created_at > now() - '1 days' :: interval;
  EOQ
}

query "digitalocean_volume_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      digitalocean_volume
    where
      created_at between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "digitalocean_volume_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      digitalocean_volume
    where
      created_at between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "digitalocean_volume_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      digitalocean_volume
    where
      created_at between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "digitalocean_volume_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      digitalocean_volume
    where
      created_at <= now() - '1 year' :: interval;
  EOQ
}

query "digitalocean_volume_age_table" {
  sql = <<-EOQ
    select
      i.name as "Name",
      i.id as "ID",
      i.filesystem_type as "Filesystem Type",
      now()::date - i.created_at::date as "Age in Days",
      i.created_at as "Create Time",
      i.region_name as "Region",
      i.urn as "URN"
    from
      digitalocean_volume as i
    order by
      i.id;
  EOQ
}
