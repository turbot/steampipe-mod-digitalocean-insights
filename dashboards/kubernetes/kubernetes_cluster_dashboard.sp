dashboard "kubernetes_cluster_dashboard" {
  title         = "DigitalOcean Kubernetes Cluster Dashboard"
  documentation = file("./dashboards/kubernetes/docs/kubernetes_cluster_dashboard.md")

  tags = merge(local.kubernetes_common_tags, {
    type = "Dashboard"
  })

  container {

    #Analysis

    card {
      query = query.kubernetes_cluster_count
      width = 3
    }

    # Assessments

    card {
      query = query.kubernetes_cluster_degraded_count
      width = 3
    }

    card {
      query = query.kubernetes_auto_upgrade_count
      width = 3
    }

    card {
      query = query.kubernetes_surge_upgrade_count
      width = 3
    }


  }

  container {

    title = "Assessments"

    chart {
      title = "Cluster Status"
      query = query.kubernetes_status
      type  = "donut"
      width = 2

      series "Clusters" {
        point "ok" {
          color = "ok"
        }
        point "degraded" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Automatic Upgrades Status"
      query = query.kubernetes_by_auto_upgrade_status
      type  = "donut"
      width = 2

      series "Clusters" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Surge Upgrades Status"
      query = query.kubernetes_by_surge_upgrade_status
      type  = "donut"
      width = 2

      series "Clusters" {
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
      title = "Kubernetes Cluster by Region"
      query = query.kubernetes_by_region
      type  = "column"
      width = 3
    }

    chart {
      title = "Kubernetes Cluster by Status"
      query = query.kubernetes_by_status
      type  = "column"
      width = 3
    }

    chart {
      title = "Kubernetes Cluster by Age"
      query = query.kubernetes_creation_month
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

query "kubernetes_cluster_count" {
  sql = <<-EOQ
    select count(*) as "Clusters" from digitalocean_kubernetes_cluster;
  EOQ
}

query "kubernetes_cluster_degraded_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Degraded' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_kubernetes_cluster
    where
      status = 'degraded';
  EOQ
}


query "kubernetes_auto_upgrade_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Automatic Upgrades Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_kubernetes_cluster
    where
      not auto_upgrade;
  EOQ
}

query "kubernetes_surge_upgrade_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Surge Upgrades Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      digitalocean_kubernetes_cluster
    where
      not surge_upgrade;
  EOQ
}

# Assessments Queries

query "kubernetes_status" {
  sql = <<-EOQ
    select
      status,
      count(*) as "Clusters"
    from (
      select name,
        case when status = 'degraded' then
          'degraded'
        else
          'ok'
        end status
      from
        digitalocean_kubernetes_cluster) as c
    group by
      status
    order by
      status;
  EOQ
}


query "kubernetes_by_auto_upgrade_status" {
  sql = <<-EOQ
    with cluster as (
      select
        case
          when not auto_upgrade then 'disabled'
          else 'enabled'
        end as u_status
      from
        digitalocean_kubernetes_cluster
    )
    select
      u_status,
      count(*) as "Clusters"
    from
      cluster
    group by
      u_status;
  EOQ
}

query "kubernetes_by_surge_upgrade_status" {
  sql = <<-EOQ
    with cluster as (
      select
        case
          when not surge_upgrade then 'disabled'
          else 'enabled'
        end as u_status
      from
        digitalocean_kubernetes_cluster
    )
    select
      u_status,
      count(*) as "Clusters"
    from
      cluster
    group by
      u_status;
  EOQ
}

# Analysis Queries

query "kubernetes_by_region" {
  sql = <<-EOQ
    select
      region_slug,
      count(d.*) as "Clusters"
    from
      digitalocean_kubernetes_cluster as d
    group by
      region_slug;
  EOQ
}

query "kubernetes_by_status" {
  sql = <<-EOQ
    select
      status,
      count(d.*) as "Clusters"
    from
      digitalocean_kubernetes_cluster as d
    group by
      status;
  EOQ
}

query "kubernetes_creation_month" {
  sql = <<-EOQ
    with kubernetes as (
      select
        title,
        created_at,
        to_char(created_at,
          'YYYY-MM') as creation_month
      from
        digitalocean_kubernetes_cluster
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
                from kubernetes)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    kubernetes_by_month as (
      select
        creation_month,
        count(*)
      from
        kubernetes
      group by
        creation_month
    )
    select
      months.month,
      kubernetes_by_month.count as "Clusters"
    from
      months
      left join kubernetes_by_month on months.month = kubernetes_by_month.creation_month
    order by
      months.month;
  EOQ
}