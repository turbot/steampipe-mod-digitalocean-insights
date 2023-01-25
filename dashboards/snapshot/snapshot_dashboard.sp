dashboard "snapshot_dashboard" {

  title         = "DigitalOcean Snapshot Dashboard"
  documentation = file("./dashboards/snapshot/docs/snapshot_dashboard.md")

  tags = merge(local.snapshot_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.snapshot_count
      width = 3
    }

    card {
      query = query.snapshot_total_storage
      width = 3
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Snapshots by Region"
      query = query.snapshot_by_region
      type  = "column"
      width = 4
    }

    chart {
      title = "Snapshots by Resource Type"
      query = query.snapshot_by_resource_type
      type  = "column"
      width = 4
    }

    chart {
      title = "Snapshots by Age"
      query = query.snapshot_creation_month
      type  = "column"
      width = 4
    }

    chart {
      title = "Storage by Region"
      query = query.storage_snapshot_by_region
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Resource Type"
      query = query.storage_snapshot_by_resource_type
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Age"
      query = query.storage_snapshot_creation_month
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }
  }
}

# Card Queries

query "snapshot_count" {
  sql = <<-EOQ
    select
      count(*) as "Snapshot"
    from
      digitalocean_snapshot;
  EOQ
}

query "snapshot_total_storage" {
  sql = <<-EOQ
    select
      sum(size_gigabytes) as "Total Storage (GB)"
    from
      digitalocean_snapshot;
  EOQ
}

# Analytics Queries

query "snapshot_by_region" {
  sql = <<-EOQ
    select
      s_regions,
      count(d.*) as "Snapshots"
    from
      digitalocean_snapshot as d,
      jsonb_array_elements(regions) as s_regions
    group by
      s_regions;
  EOQ
}

query "snapshot_by_resource_type" {
  sql = <<-EOQ
    select
      resource_type,
      count(d.*) as "Snapshots"
    from
      digitalocean_snapshot as d
    group by
      resource_type;
  EOQ
}

query "snapshot_creation_month" {
  sql = <<-EOQ
    with snapshots as (
      select
        title,
        created_at,
        to_char(created_at,
          'YYYY-MM') as creation_month
      from
        digitalocean_snapshot
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
            (
              select
                min(created_at)
                from snapshots)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    snapshots_by_month as (
      select
        creation_month,
        count(*)
      from
        snapshots
      group by
        creation_month
    )
    select
      months.month,
      snapshots_by_month.count as "Snapshots"
    from
      months
      left join snapshots_by_month on months.month = snapshots_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "storage_snapshot_by_region" {
  sql = <<-EOQ
    select
      s_regions,
      sum(size_gigabytes) as "GB"
    from
      digitalocean_snapshot as d,
      jsonb_array_elements(regions) as s_regions
    group by
      s_regions;
  EOQ
}

query "storage_snapshot_by_resource_type" {
  sql = <<-EOQ
    select
      resource_type,
      sum(size_gigabytes) as "GB"
    from
      digitalocean_snapshot as d
    group by
      resource_type;
  EOQ
}

query "storage_snapshot_creation_month" {
  sql = <<-EOQ
    with snapshots as (
      select
        title,
        size_gigabytes,
        created_at,
        to_char(created_at,
          'YYYY-MM') as creation_month
      from
        digitalocean_snapshot
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
            (
              select
                min(created_at)
                from snapshots)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    snapshots_by_month as (
      select
        creation_month,
        sum(size_gigabytes)
      from
        snapshots
      group by
        creation_month
    )
    select
      months.month,
      snapshots_by_month.sum as "GB"
    from
      months
      left join snapshots_by_month on months.month = snapshots_by_month.creation_month
    order by
      months.month;
  EOQ
}
