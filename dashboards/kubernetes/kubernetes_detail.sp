dashboard "kubernetes_cluster_detail" {

  title         = "DigitalOcean Kubernetes Cluster Detail"
  documentation = file("./dashboards/kubernetes/docs/kubernetes_detail.md")

  tags = merge(local.kubernetes_common_tags, {
    type = "Detail"
  })

  input "cluster_urn" {
    title = "Select a cluster:"
    query = query.kubernetes_cluster_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kubernetes_cluster_detail_status
      args = [self.input.cluster_urn.value]
    }

    card {
      width = 2
      query = query.kubernetes_cluster_auto_upgrade_status
      args = [self.input.cluster_urn.value]
    }

    card {
      width = 2
      query = query.kubernetes_cluster_surge_upgrade_status
      args = [self.input.cluster_urn.value]
    }
  }

  # with "kubernetes_cluster_node_pools_for_kubernetes_cluster" {
  #   query = query.kubernetes_cluster_node_pools_for_kubernetes_cluster
  #   args  = [self.input.cluster_urn.value]
  # }

  with "kubernetes_cluster_nodes_for_kubernetes_cluster" {
      query = query.kubernetes_cluster_nodes_for_kubernetes_cluster
      args  = [self.input.cluster_urn.value]
  }

  with "network_vpcs_for_kubernetes_cluster" {
      query = query.network_vpcs_for_kubernetes_cluster
      args  = [self.input.cluster_urn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_urns = [self.input.cluster_urn.value]
        }
      }

      node {
        base = node.kubernetes_cluster_node
        args = {
          kubernetes_cluster_node_urns = with.kubernetes_cluster_nodes_for_kubernetes_cluster.rows[*].node_urn
        }
      }

      node {
        base = node.network_vpc
        args = {
          network_vpc_urns = with.network_vpcs_for_kubernetes_cluster.rows[*].vpc_urn
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_kubernetes_cluster_node
        args = {
          kubernetes_cluster_urns = [self.input.cluster_urn.value]
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_network_vpc
        args = {
          kubernetes_cluster_urns = [self.input.cluster_urn.value]
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
        query = query.kubernetes_cluster_overview
        args = [self.input.cluster_urn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.kubernetes_cluster_tags
        args = [self.input.cluster_urn.value]
      }
    }

    container {

      width = 6

      table {
        title = "Node Details"
        query = query.kubernetes_cluster_node_pool_details
        args = [self.input.cluster_urn.value]

        column "URN" {
          display = "none"
        }

        column "Name" {
          href = "${dashboard.droplet_detail.url_path}?input.droplet_urn={{.'URN' | @uri}}"
        }
      }
    }
  }

  container {

    container {

      width = 10

      table {
        title = "VPC Details"
        query = query.kubernetes_cluster_network_vpc_details
        args = [self.input.cluster_urn.value]
      }
    }

  }

}

# Input queries

query "kubernetes_cluster_input" {
  sql = <<-EOQ
    select
      title as label,
      urn as value,
      json_build_object(
        'region', region_slug,
        'id', id
      ) as tags
    from
      digitalocean_kubernetes_cluster
    order by
      title;
  EOQ
}

# With queries

query "kubernetes_cluster_nodes_for_kubernetes_cluster" {
  sql = <<-EOQ
    select
      d.urn as node_urn
    from
      digitalocean_kubernetes_cluster as k,
      jsonb_array_elements(k.node_pools) as node_pool,
      jsonb_array_elements(node_pool -> 'nodes') as node,
      digitalocean_droplet as d
    where
      d.id::text = node ->> 'droplet_id'
      and k.urn = $1;
  EOQ
}

query "network_vpcs_for_kubernetes_cluster" {
  sql = <<-EOQ
    select
      v.urn as vpc_urn
    from
      digitalocean_kubernetes_cluster as k,
      digitalocean_vpc as v
    where
      v.id = k.vpc_uuid
      and k.urn = $1;
  EOQ
}

# Card queries

query "kubernetes_cluster_detail_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      initcap(status) as value
    from
      digitalocean_kubernetes_cluster
    where
      urn = $1;
  EOQ
}

query "kubernetes_cluster_auto_upgrade_status" {
  sql = <<-EOQ
    select
      'Automatic Upgrades' as label,
      case
        when auto_upgrade then 'Enabled'
        else 'Disabled'
      end as value,
      case
        when auto_upgrade then 'ok'
        else 'alert'
      end as "type"
    from
      digitalocean_kubernetes_cluster
    where
      urn = $1;
  EOQ
}

query "kubernetes_cluster_surge_upgrade_status" {
  sql = <<-EOQ
    select
      'Surge Upgrades' as label,
      case
        when surge_upgrade then 'Enabled'
        else 'Disabled'
      end as value,
      case
        when surge_upgrade then 'ok'
        else 'alert'
      end as "type"
    from
      digitalocean_kubernetes_cluster
    where
      urn = $1;
  EOQ
}

# Other detail page queries

query "kubernetes_cluster_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      created_at as "Create Time",
      cluster_subnet as "Cluster Subnet",
      service_subnet as "Service Subnet",
      version_slug as "Version Slug",
      title as "Title",
      region_slug as "Region Slug",
      urn as "URN"
    from
      digitalocean_kubernetes_cluster
    where
      urn = $1
  EOQ
}

query "kubernetes_cluster_tags" {
  sql = <<-EOQ
    select
      tag.key as "Key",
      tag.value as "Value"
    from
      digitalocean_kubernetes_cluster
      join jsonb_each_text(tags) tag on true
    where
      urn = $1
    order by
      tag.key;
  EOQ
}

query "kubernetes_cluster_node_pool_details" {
  sql = <<-EOQ
    select
      node ->> 'name' as "Name",
      node -> 'status' ->> 'state' "State",
      node_pool ->> 'name' as "Node Pool Name",
      'do:droplet:' || (node ->> 'droplet_id') as "URN"
    from
      digitalocean_kubernetes_cluster as kc,
      jsonb_array_elements(kc.node_pools) as node_pool,
      jsonb_array_elements(node_pool -> 'nodes') as node
    where
      kc.urn = $1
    order by
      node ->> 'name';
  EOQ
}

query "kubernetes_cluster_network_vpc_details" {
  sql = <<-EOQ
    select
      vpc.name as "Name",
      vpc.id as "ID",
      vpc.ip_range as "IP Range",
      vpc.created_at as "Create Time"
    from
      digitalocean_kubernetes_cluster as k
    join
      digitalocean_vpc vpc
      on vpc.id = k.vpc_uuid
    where
      k.urn = $1
    order by
      vpc.name;
  EOQ
}
