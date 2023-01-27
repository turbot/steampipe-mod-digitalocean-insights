dashboard "droplet_dashboard" {
  title         = "DigitalOcean Droplet Dashboard"
  documentation = file("./dashboards/droplet/docs/droplet_dashboard.md")

  tags = merge(local.droplet_common_tags, {
    type = "Dashboard"
  })

  container {

    #Analysis

    card {
      query = query.droplet_count
      width = 2
    }

    card {
      query = query.droplet_total_size
      width = 2
    }

    # Assessments

    card {
      query = query.droplet_publicly_accessible
      width = 2
    }

    card {
      query = query.droplet_backup_disabled
      width = 2
    }

    card {
      query = query.droplet_monitoring_status_count
      width = 2
    }


  }

  container {

    title = "Assessments"

    chart {
      title = "Public/Private"
      query = query.droplet_by_public_access
      type  = "donut"
      width = 3

      series "Droplets" {
        point "private" {
          color = "ok"
        }
        point "public" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Backups Status"
      query = query.droplet_by_backup_status
      type  = "donut"
      width = 3

      series "Droplets" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Monitoring Status"
      query = query.droplet_by_monitoring_status
      type  = "donut"
      width = 3

      series "Droplets" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Droplets by Region"
      query = query.droplet_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "Droplets by Status"
      query = query.droplet_by_status
      type  = "column"
      width = 3
    }

    chart {
      title = "Droplets by Age"
      query = query.droplet_creation_month
      type  = "column"
      width = 3
    }

    chart {
      title = "Droplets by Distribution Type"
      query = query.droplet_by_distribution_type
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

query "droplet_count" {
  sql = <<-EOQ
    select count(*) as "Droplets" from digitalocean_droplet;
  EOQ
}

query "droplet_total_size" {
  sql = <<-EOQ
    select sum(disk) as "Total Storage (GB)" from digitalocean_droplet;
  EOQ
}

query "droplet_publicly_accessible" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Publicly Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_droplet
    where
      image ->> 'public' = 'true';
  EOQ
}

query "droplet_backup_disabled" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Backups Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_droplet
    where
      not features ? 'backups';
  EOQ
}

query "droplet_monitoring_status_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Monitoring Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_droplet
    where
      not features ? 'monitoring';
  EOQ
}

# Assessment Queries

query "droplet_by_public_access" {
  sql = <<-EOQ
    with droplets as (
      select
        case
          when image ->> 'public' = 'true' then 'public'
          else 'private'
        end as public_access
      from
        digitalocean_droplet
    )
    select
      public_access,
      count(*) as "Droplets"
    from
      droplets
    group by
      public_access;
  EOQ
}

query "droplet_by_backup_status" {
  sql = <<-EOQ
    with droplets as (
      select
        case
          when not features ? 'backups' then 'disabled'
          else 'enabled'
        end as backup_status
      from
        digitalocean_droplet
    )
    select
      backup_status,
      count(*) as "Droplets"
    from
      droplets
    group by
      backup_status;
  EOQ
}

query "droplet_by_monitoring_status" {
  sql = <<-EOQ
    with droplets as (
      select
        case
          when not features ? 'monitoring' then 'disabled'
          else 'enabled'
        end as backup_status
      from
        digitalocean_droplet
    )
    select
      backup_status,
      count(*) as "Droplets"
    from
      droplets
    group by
      backup_status;
  EOQ
}

# Analytics Queries

query "droplet_by_region" {
  sql = <<-EOQ
    select
      region ->> 'name',
      count(d.*) as "Droplets"
    from
      digitalocean_droplet as d
    group by
      region;
  EOQ
}

query "droplet_by_status" {
  sql = <<-EOQ
    select
      status,
      count(d.*) as "Droplets"
    from
      digitalocean_droplet as d
    group by
      status;
  EOQ
}

query "droplet_creation_month" {
  sql = <<-EOQ
    with droplets as (
      select
        title,
        created_at,
        to_char(created_at,
          'YYYY-MM') as creation_month
      from
        digitalocean_droplet
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
                from droplets)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    droplets_by_month as (
      select
        creation_month,
        count(*)
      from
        droplets
      group by
        creation_month
    )
    select
      months.month,
      droplets_by_month.count as "Droplets"
    from
      months
      left join droplets_by_month on months.month = droplets_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "droplet_by_distribution_type" {
  sql = <<-EOQ
    select
      image ->> 'distribution',
      count(d.*) as "Droplets"
    from
      digitalocean_droplet as d
    group by
      image ->> 'distribution';
  EOQ
}
