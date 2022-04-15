dashboard "digitalocean_kubernetes_age_report" {

  title         = "DigitalOcean Kubernetes Age Report"
  documentation = file("./dashboards/kubernetes/docs/kubernetes_report_age.md")

  tags = merge(local.kubernetes_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.digitalocean_kubernetes_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_kubernetes_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_kubernetes_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.digitalocean_kubernetes_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.digitalocean_kubernetes_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.digitalocean_kubernetes_1_year_count
    }

  }

  table {
    
    column "URN" {
      display = "none"
    }

    query = query.digitalocean_kubernetes_age_table
  }

}

query "digitalocean_kubernetes_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      digitalocean_kubernetes_cluster
    where
      created_at > now() - '1 days' :: interval;
  EOQ
}

query "digitalocean_kubernetes_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      digitalocean_kubernetes_cluster
    where
      created_at between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "digitalocean_kubernetes_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      digitalocean_kubernetes_cluster
    where
      created_at between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "digitalocean_kubernetes_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      digitalocean_kubernetes_cluster
    where
      created_at between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "digitalocean_kubernetes_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      digitalocean_kubernetes_cluster
    where
      created_at <= now() - '1 year' :: interval;
  EOQ
}

query "digitalocean_kubernetes_age_table" {
  sql = <<-EOQ
    select
      i.id as "ID",
      i.name as "Name",
      now()::date - i.created_at::date as "Age in Days",
      i.created_at as "Start Time",
      i.status as "Status",
      i.region_slug as "Region",
      i.urn as "URN"
    from
      digitalocean_kubernetes_cluster as i
    order by
      i.id;
  EOQ
}
