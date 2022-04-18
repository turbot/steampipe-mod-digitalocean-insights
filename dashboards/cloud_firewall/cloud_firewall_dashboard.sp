dashboard "digitalocean_cloud_firewall_dashboard" {
  title         = "DigitalOcean Cloud Firewall Dashboard"
  documentation = file("./dashboards/cloud_firewall/docs/cloud_firewall_dashboard.md")

  tags = merge(local.cloud_firewall_common_tags, {
    type = "Dashboard"
  })

  container {

    #Analysis
    card {
      query = query.digitalocean_firewall_count
      width = 2
    }

  }

  container {

    title = "Analysis"
    width = 12

    chart {
      title = "Firewalls by Status"
      query = query.digitalocean_firewall_by_status
      type  = "column"
      width = 6
    }

    chart {
      title = "Firewalls by Age"
      query = query.digitalocean_firewall_creation_month
      type  = "column"
      width = 6
    }

  }

}

# Card Queries

query "digitalocean_firewall_count" {
  sql = <<-EOQ
    select count(*) as "Firewalls" from digitalocean_firewall;
  EOQ
}

# Analysis Queries

query "digitalocean_firewall_by_status" {
  sql = <<-EOQ
    select
      status,
      count(d.*) as "Firewalls"
    from
      digitalocean_firewall as d
    group by
      status;
  EOQ
}

query "digitalocean_firewall_creation_month" {
  sql = <<-EOQ
    with firewalls as (
      select
        title,
        created_at,
        to_char(created_at,
          'YYYY-MM') as creation_month
      from
        digitalocean_firewall
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
                from firewalls)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    firewalls_by_month as (
      select
        creation_month,
        count(*)
      from
        firewalls
      group by
        creation_month
    )
    select
      months.month,
      firewalls_by_month.count as "Firewalls"
    from
      months
      left join firewalls_by_month on months.month = firewalls_by_month.creation_month
    order by
      months.month;
  EOQ
}
