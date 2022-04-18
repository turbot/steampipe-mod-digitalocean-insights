dashboard "digitalocean_block_storage_volume_dashboard" {

  title         = "DigitalOcean Block Storage Volume Dashboard"
  documentation = file("./dashboards/block_storage_volume/docs/block_storage_volume_dashboard.md")

  tags = merge(local.block_storage_volume_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.digitalocean_volume_count
      width = 2
    }

    card {
      query = query.digitalocean_volume_total_storage
      width = 2
    }

    # Assessment

    card {
      query = query.digitalocean_volume_droplet_attached_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Volume State"
      query = query.digitalocean_volume_by_droplet_attached
      type  = "donut"
      width = 4

      series "Volume" {
        point "in-use" {
          color = "ok"
        }
        point "available" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Volumes by Region"
      query = query.digitalocean_volume_by_region
      type  = "column"
      width = 4
    }

    chart {
      title = "Volumes by Filesystem Type"
      query = query.digitalocean_volume_by_filesystem_type
      type  = "column"
      width = 4
    }

    chart {
      title = "Volumes by Age"
      query = query.digitalocean_volume_creation_month
      type  = "column"
      width = 4
    }

    chart {
      title = "Storage by Region"
      query = query.digitalocean_storage_volume_by_region
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Filesystem Type"
      query = query.digitalocean_storage_by_filesystem_type
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Age"
      query = query.digitalocean_storage_volume_creation_month
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }
  }
}

# Card Queries

query "digitalocean_volume_count" {
  sql = <<-EOQ
    select
      count(*) as "Volumes"
    from
      digitalocean_volume;
  EOQ
}

query "digitalocean_volume_total_storage" {
  sql = <<-EOQ
    select
      sum(size_gigabytes) as "Total Storage (GB)"
    from
      digitalocean_volume;
  EOQ
}

query "digitalocean_volume_droplet_attached_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Not In-Use' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_volume
    where
      jsonb_array_length(droplet_ids) = 0;
  EOQ
}

# Assessment queries

query "digitalocean_volume_by_droplet_attached" {
  sql = <<-EOQ
    with volume as (
      select
        case
          when jsonb_array_length(droplet_ids) = 0 then 'available'
          else 'in-use'
        end as droplet_attached
      from
        digitalocean_volume
    )
    select
      droplet_attached,
      count(*) as "Volume"
    from
      volume
    group by
      droplet_attached;
  EOQ
}

# Analytics Queries

query "digitalocean_volume_by_region" {
  sql = <<-EOQ
    select
      region_name,
      count(d.*) as "Volumes"
    from
      digitalocean_volume as d
    group by
      region_name;
  EOQ
}

query "digitalocean_volume_by_filesystem_type" {
  sql = <<-EOQ
    select
      filesystem_type,
      count(d.*) as "Volumes"
    from
      digitalocean_volume as d
    where
      filesystem_type is not null
    group by
      filesystem_type;
  EOQ
}

query "digitalocean_volume_creation_month" {
  sql = <<-EOQ
    with volumes as (
      select
        title,
        created_at,
        to_char(created_at,
          'YYYY-MM') as creation_month
      from
        digitalocean_volume
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
                from volumes)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    volumes_by_month as (
      select
        creation_month,
        count(*)
      from
        volumes
      group by
        creation_month
    )
    select
      months.month,
      volumes_by_month.count as "Volumes"
    from
      months
      left join volumes_by_month on months.month = volumes_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "digitalocean_storage_volume_by_region" {
  sql = <<-EOQ
    select
      region_name,
      sum(size_gigabytes) as "GB"
    from
      digitalocean_volume as d
    group by
      region_name;
  EOQ
}

query "digitalocean_storage_by_filesystem_type" {
  sql = <<-EOQ
    select
      filesystem_type,
      sum(size_gigabytes) as "GB"
    from
      digitalocean_volume as d
    where
      filesystem_type is not null
    group by
      filesystem_type;
  EOQ
}

query "digitalocean_storage_volume_creation_month" {
  sql = <<-EOQ
    with volumes as (
      select
        title,
        size_gigabytes,
        created_at,
        to_char(created_at,
          'YYYY-MM') as creation_month
      from
        digitalocean_volume
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
                from volumes)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    volumes_by_month as (
      select
        creation_month,
        sum(size_gigabytes)
      from
        volumes
      group by
        creation_month
    )
    select
      months.month,
      volumes_by_month.sum as "GB"
    from
      months
      left join volumes_by_month on months.month = volumes_by_month.creation_month
    order by
      months.month;
  EOQ
}
