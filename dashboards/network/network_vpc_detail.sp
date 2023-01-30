dashboard "network_vpc_detail" {

  title = "DigitalOcean VPC Detail"
  documentation = file("./dashboards/network/docs/network_vpc_detail.md")

  tags = merge(local.network_common_tags, {
    type = "Detail"
  })

  input "vpc_urn" {
    title = "Select a VPC:"
    query = query.network_vpc_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.network_vpc_ip_range
      args  = [self.input.vpc_urn.value]
    }

    card {
      width = 3
      query = query.network_vpc_is_default
      args  = [self.input.vpc_urn.value]
    }

  }

  with "database_clusters_for_network_vpc" {
    query = query.database_clusters_for_network_vpc
    args  = [self.input.vpc_urn.value]
  }

  with "droplet_droplets_for_network_vpc" {
    query = query.droplet_droplets_for_network_vpc
    args  = [self.input.vpc_urn.value]
  }

  with "kubernetes_clusters_for_network_vpc" {
    query = query.kubernetes_clusters_for_network_vpc
    args  = [self.input.vpc_urn.value]
  }

  with "network_firewalls_for_network_vpc" {
    query = query.network_firewalls_for_network_vpc
    args  = [self.input.vpc_urn.value]
  }

  with "network_load_balancers_for_network_vpc" {
    query = query.network_load_balancers_for_network_vpc
    args  = [self.input.vpc_urn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.database_cluster
        args = {
          database_cluster_urns = with.database_clusters_for_network_vpc.rows[*].database_cluster_urn
        }
      }

      node {
        base = node.droplet_droplet
        args = {
          droplet_droplet_urns = with.droplet_droplets_for_network_vpc.rows[*].droplet_urn
        }
      }

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_urns = with.kubernetes_clusters_for_network_vpc.rows[*].kube_cluster_urn
        }
      }

      node {
        base = node.network_firewall
        args = {
          network_firewall_urns = with.network_firewalls_for_network_vpc.rows[*].firewall_urn
        }
      }

      node {
        base = node.network_load_balancer
        args = {
          network_load_balancer_urns = with.network_load_balancers_for_network_vpc.rows[*].lb_urn
        }
      }

      node {
        base = node.network_vpc
        args = {
          network_vpc_urns = [self.input.vpc_urn.value]
        }
      }

      edge {
        base = edge.network_firewall_to_droplet_droplet
        args = {
          network_firewall_urns = with.network_firewalls_for_network_vpc.rows[*].firewall_urn
        }
      }

      edge {
        base = edge.network_vpc_to_database_cluster
        args = {
          network_vpc_urns = [self.input.vpc_urn.value]
        }
      }

      edge {
        base = edge.network_vpc_to_droplet_droplet
        args = {
          network_vpc_urns = [self.input.vpc_urn.value]
        }
      }

      edge {
        base = edge.network_vpc_to_kubernetes_cluster
        args = {
          network_vpc_urns = [self.input.vpc_urn.value]
        }
      }

      edge {
        base = edge.network_vpc_to_network_firewall
        args = {
          network_vpc_urns = [self.input.vpc_urn.value]
        }
      }

      edge {
        base = edge.network_vpc_to_network_load_balancer
        args = {
          network_vpc_urns = [self.input.vpc_urn.value]
        }
      }

    }
  }

  container {

      container {

        width = 6

        table {
          title = "Overview"
          type  = "line"
          width = 6
          query = query.network_vpc_overview
          args  = [self.input.vpc_urn.value]
        }

        table {
          title = "Tags"
          width = 6
          query = query.network_vpc_tags
          args  = [self.input.vpc_urn.value]
        }
      }

      container {

        width = 6

        table {
          title = "Attached Resources"
          query = query.network_vpc_association
          args  = [self.input.vpc_urn.value]

          column "link" {
            display = "none"
          }

          column "Title" {
            href = "{{ .link }}"
          }

        }

      }

    }

  }


# Input queries

query "network_vpc_input" {
  sql = <<-EOQ
    select
      title as label,
      urn as value,
      json_build_object(
        'id', id
      ) as tags
    from
      digitalocean_vpc
    order by
      title;
  EOQ
}

# With queries

query "database_clusters_for_network_vpc" {
  sql = <<-EOQ
    select
      d.urn as database_cluster_urn
    from
      digitalocean_database as d,
      digitalocean_vpc as v
    where
      v.id = d.private_network_uuid
      and v.urn = $1;
  EOQ
}

query "droplet_droplets_for_network_vpc" {
  sql = <<-EOQ
    select
      d.urn as droplet_urn
    from
      digitalocean_droplet as d,
      digitalocean_vpc as v
    where
      v.id = d.vpc_uuid
      and v.urn = $1;
  EOQ
}

query "kubernetes_clusters_for_network_vpc" {
  sql = <<-EOQ
    select
      k.urn as kube_cluster_urn
    from
      digitalocean_vpc as v,
      digitalocean_kubernetes_cluster as k
    where
      v.id = k.vpc_uuid
      and v.urn = $1;
  EOQ
}

query "network_firewalls_for_network_vpc" {
  sql = <<-EOQ
    select
      f.urn as firewall_urn
    from
      digitalocean_firewall as f,
      jsonb_array_elements_text(droplet_ids) as did,
      digitalocean_droplet as d,
      digitalocean_vpc as v
    where
      d.vpc_uuid = v.id
      and did = d.id::text
      and v.urn = $1;
  EOQ
}

query "network_load_balancers_for_network_vpc" {
  sql = <<-EOQ
    select
      l.urn as lb_urn
    from
      digitalocean_load_balancer as l,
      digitalocean_vpc as v
    where
      v.id = l.vpc_uuid
      and v.urn = $1;
  EOQ
}

# Card queries

query "network_vpc_is_default" {
  sql = <<-EOQ
    select
      'Default VPC' as label,
      case when not is_default then 'Ok' else 'Default VPC' end as value,
      case when not is_default then 'ok' else 'alert' end as type
    from
      digitalocean_vpc
    where
      urn = $1;
  EOQ

}

query "network_vpc_ip_range" {
  sql = <<-EOQ
    select
      'IP Range' as label,
      ip_range as value
    from
      digitalocean_vpc
    where
      urn = $1;
  EOQ
}

## Other detail page queries

query "network_vpc_overview" {
  sql = <<-EOQ
    select
      title as "Title",
      id as "ID",
      created_at as "Create Time",
      ip_range as "IP Range",
      region_slug as "Region",
      urn as "URN"
    from
      digitalocean_vpc
    where
      urn = $1;
  EOQ
}

query "network_vpc_tags" {
  sql = <<-EOQ
    select
      tag.key as "Key",
      tag.value as "Value"
    from
      digitalocean_vpc
      join jsonb_each_text(tags) tag on true
    where
      urn = $1
    order by
      tag.key;
  EOQ
}

query "network_vpc_association" {
  sql = <<-EOQ
    -- Droplets
    select
      d.title as "Title",
      'digitalocean_droplet' as "Type",
      d.urn as "URN",
      '${dashboard.droplet_detail.url_path}?input.droplet_urn=' || d.urn as link
    from
      digitalocean_droplet as d,
      digitalocean_vpc as v
    where
      v.id = d.vpc_uuid
      and v.urn = $1

    -- Databases
    union all
    select
      d.title as "Title",
      'digitalocean_database' as "Type",
      d.urn as "URN",
      '${dashboard.database_cluster_detail.url_path}?input.database_cluster_urn=' || d.urn as link
    from
      digitalocean_database as d,
      digitalocean_vpc as v
    where
      v.id = d.private_network_uuid
      and v.urn = $1

    -- Load Balancers
    union all
    select
      l.title as "Title",
      'digitalocean_load_balancer' as "Type",
      l.urn as "URN",
      null as link
    from
      digitalocean_load_balancer as l,
      digitalocean_vpc as v
    where
      v.id = l.vpc_uuid
      and v.urn = $1
  EOQ
}