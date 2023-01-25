dashboard "network_vpc_dashboard" {
  title         = "DigitalOcean VPC Dashboard"
  documentation = file("./dashboards/network/docs/network_vpc_dashboard.md")

  tags = merge(local.network_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis

    card {
      query = query.network_vpc_count
      width = 3
    }

    card {
      query = query.network_vpc_default_count
      width = 3
    }

  }
  container {

    title = "Assessment"

    chart {
      title = "Default VPCs"
      type  = "donut"
      width = 4
      query = query.network_vpc_default_status

      series "count" {
        point "non-default" {
          color = "ok"
        }
        point "default" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "VPCs by Age"
      query = query.network_vpc_creation_month
      type  = "column"
      width = 4
    }

    chart {
      title = "VPCs by Region"
      query = query.network_vpc_by_region
      type  = "column"
      width = 4
    }

    chart {
      title = "VPCs by RFC1918 Range"
      query = query.network_vpc_by_rfc1918_range
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "network_vpc_count" {
  sql = <<-EOQ
    select count(*) as "VPCs" from digitalocean_vpc;
  EOQ
}

query "network_vpc_default_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Default VPCs' as label,
      case count(*) when 0 then 'ok' else 'alert' end as type
    from
      digitalocean_vpc
    where
      is_default;
  EOQ
}

# # Assessment Queries

query "network_vpc_default_status" {
  sql = <<-EOQ
    select
      case
        when is_default then 'default'
        else 'non-default'
      end as default_status,
      count(*)
    from
      digitalocean_vpc
    group by
      is_default;
  EOQ
}

# # Analysis Queries

query "network_vpc_creation_month" {
  sql = <<-EOQ
    with vpcs as (
      select
        title,
        created_at,
        to_char(created_at,
          'YYYY-MM') as creation_month
      from
        digitalocean_vpc
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
                from vpcs)),
            date_trunc('month',
              current_date),
            interval '1 month') as d
    ),
    vpcs_by_month as (
      select
        creation_month,
        count(*)
      from
        vpcs
      group by
        creation_month
    )
    select
      months.month,
      vpcs_by_month.count as "VPCs"
    from
      months
      left join vpcs_by_month on months.month = vpcs_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "network_vpc_by_region" {
  sql = <<-EOQ
    select
      region_slug as "Region",
      count(*) as "VPCs"
    from
      digitalocean_vpc
    group by
      region_slug
    order by
      region_slug;
  EOQ
}

query "network_vpc_by_rfc1918_range" {
  sql = <<-EOQ
    with cidr_buckets as (
      select
        id,
        title,
        ip_range as cidr,
        case
          when ip_range <<= '10.0.0.0/8'::cidr then '10.0.0.0/8'
          when ip_range <<= '172.16.0.0/12'::cidr then '172.16.0.0/12'
          when ip_range <<= '192.168.0.0/16'::cidr then '192.168.0.0/16'
          else 'Public Range'
        end as rfc1918_bucket
      from
        digitalocean_vpc
    )
    select
      rfc1918_bucket,
      count(*)
    from
      cidr_buckets
    group by
      rfc1918_bucket
    order by
      rfc1918_bucket
  EOQ
}
