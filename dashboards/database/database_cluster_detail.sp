dashboard "database_cluster_detail" {

  title = "DigitalOcean Database Cluster Detail"
  documentation = file("./dashboards/database/docs/database_cluster_detail.md")

  tags = merge(local.database_common_tags, {
    type = "Detail"
  })

  input "database_cluster_urn" {
    title = "Select a database cluster:"
    query = query.database_cluster_input
    width = 4
  }

    container {

      card {
        width = 2
        query = query.database_cluster_node_count
        args = [self.input.database_cluster_urn.value]
      }

      card {
        width = 2
        query = query.database_cluster_connection_port
        args = [self.input.database_cluster_urn.value]
      }

      card {
        width = 2
        query = query.database_cluster_engine_version
        args = [self.input.database_cluster_urn.value]
      }

      card {
        width = 2
        query = query.database_cluster_ssl_enabled
        args = [self.input.database_cluster_urn.value]
      }

      card {
        width = 2
        query = query.database_cluster_firewall_enabled
        args = [self.input.database_cluster_urn.value]
      }

      card {
        width = 2
        query = query.database_cluster_maintenance_window_pending
        args = [self.input.database_cluster_urn.value]
      }

    }

    with "network_vpcs_for_database_cluster" {
      query = query.network_vpcs_for_database_cluster
      args  = [self.input.database_cluster_urn.value]
    }

    container {

      graph {
        title     = "Relationships"
        type      = "graph"
        direction = "TD"

        node {
          base = node.database_cluster
          args = {
            database_cluster_urns = [self.input.database_cluster_urn.value]
          }
        }

        node {
          base = node.network_vpc
          args = {
            network_vpc_urns = with.network_vpcs_for_database_cluster.rows[*].vpc_urn
          }
        }

        edge {
          base = edge.database_cluster_to_network_vpc
          args = {
            database_cluster_urns = [self.input.database_cluster_urn.value]
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
          query = query.database_cluster_overview
          args = [self.input.database_cluster_urn.value]
        }

        table {
          title = "Tags"
          width = 6
          query = query.database_cluster_tags
          args = [self.input.database_cluster_urn.value]
        }
      }

      container {

        width = 6

        table {
          title = "Maintenance Window Details"
          query = query.database_cluster_maintenance_window
          args = [self.input.database_cluster_urn.value]
        }

      }

    }

    container {

      table {
        title = "Private Connection Details"
        query = query.database_cluster_private_connection
        args  = [self.input.database_cluster_urn.value]
      }
    }

  }


# # Input queries

query "database_cluster_input" {
  sql = <<-EOQ
    select
      title as label,
      urn as value,
      json_build_object(
        'id', id
      ) as tags
    from
      digitalocean_database
    order by
      title;
  EOQ
}

# # With queries

query "network_vpcs_for_database_cluster" {
  sql = <<-EOQ
    select
      v.urn as vpc_urn
    from
      digitalocean_database as d,
      digitalocean_vpc as v
    where
      v.id = d.private_network_uuid
      and d.urn = $1;
  EOQ
}

# # Card queries

query "database_cluster_node_count" {
  sql = <<-EOQ
    select
      'Nodes' as label,
      num_nodes as value
    from
      digitalocean_database
    where
      urn = $1;
  EOQ
}

query "database_cluster_connection_port" {
  sql = <<-EOQ
    select
      connection_port as "Connection Port"
    from
      digitalocean_database
    where
      urn = $1;
  EOQ
}

query "database_cluster_ssl_enabled" {
  sql = <<-EOQ
    select
      'SSL' as label,
      case when connection_ssl then 'Enabled' else 'Disabled' end as value,
      case when connection_ssl then 'ok' else 'alert' end as type
    from
      digitalocean_database
    where
      urn = $1;
  EOQ
}

query "database_cluster_firewall_enabled" {
  sql = <<-EOQ
    select
      'Firewall' as label,
      case when jsonb_array_length(firewall_rules) = 0 then 'Disabled' else 'Enabled' end as value,
      case when jsonb_array_length(firewall_rules) = 0 then 'alert' else 'ok' end as type
    from
      digitalocean_database
    where
      urn = $1;
  EOQ
}

query "database_cluster_maintenance_window_pending" {
  sql = <<-EOQ
    select
      'Maintenance Window' as label,
      case when maintenance_window_pending then 'Not Pending' else 'Pending' end as value,
      case when maintenance_window_pending then 'ok' else 'alert' end as type
    from
      digitalocean_database
    where
      urn = $1;
  EOQ
}

query "database_cluster_engine_version" {
  sql = <<-EOQ
    select
      'Engine Version' as label,
      version as value
    from
      digitalocean_database
    where
      urn = $1;
  EOQ
}

query "database_cluster_overview" {
  sql = <<-EOQ
    select
      title as "Title",
      id as "ID",
      created_at as "Create Time",
      size_slug as "Size",
      name as "Name",
      status as "Status",
      region_slug as "Region",
      urn as "URN"
    from
      digitalocean_database
    where
      urn = $1;
  EOQ
}

query "database_cluster_tags" {
  sql = <<-EOQ
    select
      tag.key as "Key",
      tag.value as "Value"
    from
      digitalocean_database
      join jsonb_each_text(tags) tag on true
    where
      urn = $1
    order by
      tag.key;
  EOQ
}

query "database_cluster_maintenance_window" {
  sql = <<-EOQ
    select
      maintenance_window_day as "Day",
      maintenance_window_description as "Description",
      maintenance_window_hour as "Hour",
      maintenance_window_pending as "Pending Status"
    from
      digitalocean_database
    where
      urn = $1;
  EOQ
}

query "database_cluster_private_connection" {
  sql = <<-EOQ
    select
      private_connection_host as "Host",
      private_connection_port as "Port",
      private_connection_ssl as "SSL Enabled",
      private_connection_uri as "URI"
    from
      digitalocean_database
    where
      urn = $1;
  EOQ
}
