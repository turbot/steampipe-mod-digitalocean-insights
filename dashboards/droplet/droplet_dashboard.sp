dashboard "digitalocean_droplet_dashboard" {
  title         = "DigitalOcean Droplet Dashboard"
  documentation = file("./dashboards/droplet/docs/droplet_dashboard.md")

  tags = merge(local.droplet_common_tags, {
    type = "Dashboard"
  })

  container {

    #Analysis
    card {
      query = query.digitalocean_droplet_count
      width = 2
    }

    card {
      query = query.digitalocean_droplet_total_size
      width = 2
    }

    # Assessments

    card {
      query = query.digitalocean_droplet_publically_accessible
      width = 2
    }

    card {
      query = query.digitalocean_droplet_backup_disabled
      width = 2
    }

    card {
      query = query.digitalocean_droplet_not_active
      width = 2
    }


  }

  container {

    title = "Assessments"

    chart {
      title = "Public/Private Access"
      query = query.digitalocean_droplet_by_public_access
      type  = "donut"
      width = 2

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
      title = "Backup Status"
      query = query.digitalocean_droplet_by_backup_status
      type  = "donut"
      width = 2

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
      title = "Droplet Status"
      query = query.digitalocean_droplet_by_availability_status
      type  = "donut"
      width = 2

      series "Droplets" {
        point "active" {
          color = "ok"
        }
        point "inactive" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Monitoring Status"
      query = query.digitalocean_droplet_by_monitoring_status
      type  = "donut"
      width = 2

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
      query = query.digitalocean_droplet_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "Droplets by Status"
      query = query.digitalocean_droplet_by_status
      type  = "column"
      width = 3
    }

    chart {
      title = "Droplets by Age"
      query = query.digitalocean_droplet_creation_month
      type  = "column"
      width = 3
    }

    chart {
      title = "Droplets by Distribution Type"
      query = query.digitalocean_droplet_by_distribution_type
      type  = "column"
      width = 3
    }

    # chart {
    #   title = "droplets by Class"
    #   query = query.alicloud_rds_instance_by_class
    #   type  = "column"
    #   width = 4
    # }

  }

}

# Card Queries

query "digitalocean_droplet_count" {
  sql = <<-EOQ
    select count(*) as "Droplets" from digitalocean_droplet;
  EOQ
}

query "digitalocean_droplet_total_size" {
  sql = <<-EOQ
    select sum(disk) as "Total Storage(GB)" from digitalocean_droplet;
  EOQ
}

query "digitalocean_droplet_publically_accessible" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Publically Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_droplet
    where
      image ->> 'public' = 'true';
  EOQ
}

query "digitalocean_droplet_backup_disabled" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Backup Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_droplet
    where
      not features ? 'backups';
  EOQ
}

query "digitalocean_droplet_not_active" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Not Active' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_droplet
    where
      status not in ('active','new');
  EOQ
}

# Assessment Queries

query "digitalocean_droplet_by_public_access" {
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

query "digitalocean_droplet_by_backup_status" {
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

query "digitalocean_droplet_by_availability_status" {
  sql = <<-EOQ
    with droplets as (
      select
        case
          when status in ('active','new') then 'active'
          else 'inactive'
        end as droplet_status
      from
        digitalocean_droplet
    )
    select
      droplet_status,
      count(*) as "Droplets"
    from
      droplets
    group by
      droplet_status;
  EOQ
}

query "digitalocean_droplet_by_monitoring_status" {
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

query "digitalocean_droplet_by_region" {
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

query "digitalocean_droplet_by_status" {
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

query "digitalocean_droplet_creation_month" {
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

query "digitalocean_droplet_by_distribution_type" {
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