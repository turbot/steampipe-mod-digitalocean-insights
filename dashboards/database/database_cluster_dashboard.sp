dashboard "digitalocean_database_cluster_dashboard" {

  title         = "DigitalOcean Database Cluster Dashboard"
  documentation = file("./dashboards/database/docs/database_cluster_dashboard.md")

  tags = merge(local.database_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis

    card {
      query = query.digitalocean_database_cluster_count
      width = 2
    }

    # Assessment

    card {
      query = query.digitalocean_database_cluster_ssl_enabled_count
      width = 2
    }

    card {
      query = query.digitalocean_database_cluster_firewall_enabled_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "SSL Status"
      query = query.digitalocean_droplet_by_ssl_status
      type  = "donut"
      width = 3

      series "Clusters" {
        point "enabled" {
          color = "ok"
        }
        point "disbled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Firewall Status"
      query = query.digitalocean_droplet_by_firewall_status
      type  = "donut"
      width = 3

      series "Clusters" {
        point "enabled" {
          color = "ok"
        }
        point "disbled" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Database Clusters by Region"
      query = query.digitalocean_database_cluster_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "Database Clusters by DB Engine"
      query = query.digitalocean_database_cluster_by_engine
      type  = "column"
      width = 3
    }

    chart {
      title = "Database Clusters by Age"
      query = query.digitalocean_database_cluster_by_creation_month
      type  = "column"
      width = 3
    }

    chart {
      title = "Database Clusters by Status"
      query = query.digitalocean_database_cluster_by_status
      type  = "column"
      width = 3
    }

  }
}

# Card Queries

query "digitalocean_database_cluster_count" {
  sql = <<-EOQ
    select 
      count(*) as "Clusters" 
    from 
      digitalocean_database;
  EOQ
}

query "digitalocean_database_cluster_ssl_enabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'SSL Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_database
    where
      not connection_ssl and not private_connection_ssl;
  EOQ
}

query "digitalocean_database_cluster_firewall_enabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Firewall Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_database
    where
      jsonb_array_length(firewall_rules) = 0;
  EOQ
}

# Assessment queries

query "digitalocean_droplet_by_ssl_status" {
  sql = <<-EOQ
    with database as (
      select
        case
          when not connection_ssl and not private_connection_ssl then 'disabled'
          else 'enabled'
        end as ssl_status
      from
        digitalocean_database
    )
    select
      ssl_status,
      count(*) as "Clusters"
    from
      database
    group by
      ssl_status;
  EOQ
}

query "digitalocean_droplet_by_firewall_status" {
  sql = <<-EOQ
    with database as (
      select
        case
          when jsonb_array_length(firewall_rules) = 0 then 'disabled'
          else 'enabled'
        end as firewall_status
      from
        digitalocean_database
    )
    select
      firewall_status,
      count(*) as "Clusters"
    from
      database
    group by
      firewall_status;
  EOQ
}

# Analytics Queries

query "digitalocean_database_cluster_by_region" {
  sql = <<-EOQ
    select
      region_slug,
      count(d.*) as "Clusters"
    from
      digitalocean_database as d
    group by
      region_slug;
  EOQ
}

query "digitalocean_database_cluster_by_engine" {
  sql = <<-EOQ
    select
      engine,
      count(d.*) as "Clusters"
    from
      digitalocean_database as d
    group by
      engine;
  EOQ
}

query "digitalocean_database_cluster_by_creation_month" {
  sql = <<-EOQ
    with databases as (
      select
        title,
        created_at,
        to_char(created_at,
          'YYYY-MM') as creation_month
      from
        digitalocean_database
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
                from databases)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    databases_by_month as (
      select
        creation_month,
        count(*)
      from
        databases
      group by
        creation_month
    )
    select
      months.month,
      databases_by_month.count as "Clusters"
    from
      months
      left join databases_by_month on months.month = databases_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "digitalocean_database_cluster_by_status" {
  sql = <<-EOQ
    select
      status,
      count(d.*) as "Clusters"
    from
      digitalocean_database as d
    group by
      status;
  EOQ
}
