dashboard "digitalocean_kubernetes_detail" {

  title         = "DigitalOcean Kubernetes Detail"
  documentation = file("./dashboards/kubernetes/docs/kubernetes_detail.md")

  tags = merge(local.kubernetes_common_tags, {
    type = "Detail"
  })

  input "cluster_urn" {
    title = "Select a cluster:"
    query = query.digitalocean_kubernetes_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.digitalocean_kubernetes_detail_status
      args = {
        urn = self.input.cluster_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_kubernetes_detail_auto_upgrade_status
      args = {
        urn = self.input.cluster_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_kubernetes_detail_surge_upgrade_status
      args = {
        urn = self.input.cluster_urn.value
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
        query = query.digitalocean_kubernetes_overview
        args = {
          urn = self.input.cluster_urn.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.digitalocean_kubernetes_tags
        args = {
          urn = self.input.cluster_urn.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Node Details"
        query = query.digitalocean_kubernetes_node_pool_details
        args = {
          urn = self.input.cluster_urn.value
        }

        column "Droplet URN" {
          display = "none"
        }

        # column "Droplet ID" {
        #   href = "${dashboard.digitalocean_droplet_detail.url_path}?input.droplet_urn={{.'URN' | @uri}}"
        # }
      }
    }
  }

  container {

    container {

      width = 10

      table {
        title = "VPC Details"
        query = query.digitalocean_kubernetes_detail_vpc_details
        args = {
          urn = self.input.cluster_urn.value
        }
      }
    }

  }

}

query "digitalocean_kubernetes_input" {
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

query "digitalocean_kubernetes_detail_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      initcap(status) as value
    from
      digitalocean_kubernetes_cluster
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_kubernetes_detail_auto_upgrade_status" {
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

  param "urn" {}
}

query "digitalocean_kubernetes_detail_surge_upgrade_status" {
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

  param "urn" {}
}

query "digitalocean_kubernetes_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "Kubernetes Cluster ID",
      created_at as "Create Time",
      cluster_subnet as "Cluster Subnet",
      service_subnet as "Service Subnet",
      version_slug as "Version",
      title as "Title",
      region_slug as "Region",
      urn as "URN"
    from
      digitalocean_kubernetes_cluster
    where
      urn = $1
  EOQ

  param "urn" {}
}

query "digitalocean_kubernetes_tags" {
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

  param "urn" {}
}

query "digitalocean_kubernetes_node_pool_details" {
  sql = <<-EOQ
    select
      node ->> 'name' as "Name",
      node -> 'status' ->> 'state' "State",
      node_pool ->> 'name' as "Node Pool Name"
    from
      digitalocean_kubernetes_cluster as kc,
      jsonb_array_elements(kc.node_pools) as node_pool,
      jsonb_array_elements(node_pool -> 'nodes') as node
    where
      kc.urn = $1
    order by
      node ->> 'name';
  EOQ

  param "urn" {}
}

query "digitalocean_kubernetes_detail_vpc_details" {
  sql = <<-EOQ
    select
      vpc.name as "Name",
      vpc.id as "ID",
      vpc.ip_range as "IP Range",
      vpc.created_at as "Create Time"
    from
      digitalocean_kubernetes_cluster
    join
      digitalocean_vpc vpc
      on vpc.id = vpc_uuid;
  EOQ

  param "urn" {}
}