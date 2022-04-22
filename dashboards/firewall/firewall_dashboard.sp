dashboard "digitalocean_cloud_firewall_dashboard" {
  title         = "DigitalOcean Firewall Dashboard"
  documentation = file("./dashboards/firewall/docs/firewall_dashboard.md")

  tags = merge(local.firewall_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis

    card {
      query = query.digitalocean_firewall_count
      width = 2
    }

    card {
      query = query.digitalocean_firewall_unrestricted_inbound_rules_count
      width = 2
    }

    card {
      query = query.digitalocean_firewall_unrestricted_outbound_rules_count
      width = 2
    }

  }
  container {

    title = "Assessment"

    chart {
      title = "With Unrestricted Inbound (Excludes ICMP)"
      type  = "donut"
      width = 3
      query = query.digitalocean_firewall_unrestricted_inbound_status

      series "Firewalls" {
        point "restricted" {
          color = "ok"
        }
        point "unrestricted" {
          color = "alert"
        }
      }
    }

    chart {
      title = "With Unrestricted Outbound (Excludes ICMP)"
      type  = "donut"
      width = 3
      query = query.digitalocean_firewall_unrestricted_outbound_status

      series "Firewalls" {
        point "restricted" {
          color = "ok"
        }
        point "unrestricted" {
          color = "alert"
        }
      }
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

query "digitalocean_firewall_unrestricted_outbound_rules_count" {
  sql = <<-EOQ
    with outbound_fw as (
      select
        id
      from
        digitalocean_firewall,
        jsonb_array_elements(outbound_rules) as i
      where
        i -> 'destinations' -> 'addresses' = '["0.0.0.0/0","::/0"]'
        and i ->> 'protocol' <> 'icmp'
      group by id
    )
    select
      'Unrestricted Outbound (Excludes ICMP)' as label,
      count(*) as value,
      case
        when count(*) = 0 then 'ok'
        else 'alert'
      end as type
    from
      outbound_fw;
  EOQ
}

query "digitalocean_firewall_unrestricted_inbound_rules_count" {
  sql = <<-EOQ
    with inbound_fw as (
      select
        id
      from
        digitalocean_firewall,
        jsonb_array_elements(inbound_rules) as i
      where
        i -> 'sources' -> 'addresses' = '["0.0.0.0/0","::/0"]'
        and i ->> 'protocol' <> 'icmp'
        group by id
    )
    select
      'Unrestricted Inbound (Excludes ICMP)' as label,
      count(*) as value,
      case
        when count(*) = 0 then 'ok'
        else 'alert'
      end as type
    from
      inbound_fw;
  EOQ
}

# Assessment Queries

query "digitalocean_firewall_unrestricted_outbound_status" {
  sql = <<-EOQ
    with outbound_fw as (
      select
        id
      from
        digitalocean_firewall,
        jsonb_array_elements(outbound_rules) as i
      where
        i -> 'destinations' -> 'addresses' = '["0.0.0.0/0","::/0"]'
        and i ->> 'protocol' <> 'icmp'
      group by id
    )
    select
      status,
      count(*) as "Firewalls"
    from
      (select
      case when ofw.id is null then 'restricted' else 'unrestricted' end as status
      from
        digitalocean_firewall as df left join outbound_fw as ofw on df.id = ofw.id ) as outbound_status
    group by status;
  EOQ
}

query "digitalocean_firewall_unrestricted_inbound_status" {
  sql = <<-EOQ
    with inbound_fw as (
      select
        id
      from
        digitalocean_firewall,
        jsonb_array_elements(inbound_rules) as i
      where
        i -> 'sources' -> 'addresses' = '["0.0.0.0/0","::/0"]'
        and i ->> 'protocol' <> 'icmp'
      group by id
    )
    select
      status,
      count(*) as "Firewalls"
    from
      (select
      case when ofw.id is null then 'restricted' else 'unrestricted' end as status
      from
        digitalocean_firewall as df left join inbound_fw as ofw on df.id = ofw.id ) as inbound_status
    group by status;
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
