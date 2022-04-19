dashboard "digitalocean_firewall_detail" {

  title         = "DigitalOcean Firewall Detail"
  documentation = file("./dashboards/firewall/docs/firewall_detail.md")

  tags = merge(local.firewall_common_tags, {
    type = "Detail"
  })

  input "firewall_urn" {
    title = "Select a firewall:"
    query = query.digitalocean_firewall_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.digitalocean_firewall_status
      args = {
        urn = self.input.firewall_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_firewall_unrestricted_inbound_rules
      args = {
        urn = self.input.firewall_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_firewall_unrestricted_outbound_rules
      args = {
        urn = self.input.firewall_urn.value
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
        query = query.digitalocean_firewall_overview
        args = {
          urn = self.input.firewall_urn.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.digitalocean_firewall_tags
        args = {
          urn = self.input.firewall_urn.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Attached To"
        query = query.digitalocean_firewall_attached
        args = {
          urn = self.input.firewall_urn.value
        }
      }

    }

  }

  container {

    flow {
      title = "Deployment Hierarchy"
      query = query.digitalocean_firewall_tree
      args = {
        urn = self.input.firewall_urn.value
      }
    }

    flow {
      title = "Deployment Hierarchy"
      query = query.digitalocean_firewall_tree
      args = {
        urn = self.input.firewall_urn.value
      }
    }

  }

}

query "digitalocean_firewall_input" {
  sql = <<-EOQ
    select
      title as label,
      urn as value,
      json_build_object(
        'id', id
      ) as tags
    from
      digitalocean_firewall
    order by
      title;
  EOQ
}

query "digitalocean_firewall_status" {
  sql = <<-EOQ
    select
      initcap(status) as "Status"
    from
      digitalocean_firewall
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_unrestricted_inbound_rules" {
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
      'Inbound (Excludes ICMP)' as label,
      case when i.id is null then 'Restricted' else 'Unrestricted' end as value,
      case when i.id is null then 'ok' else 'alert' end as type
      from
        digitalocean_firewall as d
        left join inbound_fw as i on d.id = i.id
      where
        d.urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_unrestricted_outbound_rules" {
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
      'Outbound (Excludes ICMP)' as label,
      case when o.id is null then 'Restricted' else 'Unrestricted' end as value,
       case when o.id is null then 'ok' else 'alert' end as type
      from
        digitalocean_firewall as d
        left join outbound_fw as o on d.id = o.id
      where
        d.urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_overview" {
  sql = <<-EOQ
    select
      title as "Title",
      id as "ID",
      created_at as "Create Date",
      urn as "URN"
    from
      digitalocean_firewall
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_tags" {
  sql = <<-EOQ
    select
      tag.key as "Key",
      tag.value as "Value"
    from
      digitalocean_firewall
      join jsonb_each_text(tags) tag on true
    where
      urn = $1
    order by
      tag.key;
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_attached" {
  sql = <<-EOQ
    select
      name as "Droplet Name",
      id as "ID",
      created_at as "Create Date"
    from
      digitalocean_droplet
    where
      id::text in (
    select
      d
    from
      digitalocean_firewall,
      jsonb_array_elements_text(droplet_ids) as d
    where
      urn = $1);
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_strategy" {
  sql = <<-EOQ
    select
      strategy ->> 'type' as "Type",
      strategy -> 'rollingUpdate' ->> 'maxSurge' as "Max Surge",
      strategy -> 'rollingUpdate' ->> 'maxUnavailable' as "Max Unavailable"
    from
      digitalocean_firewall
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_replicas_detail" {
  sql = <<-EOQ
    select
      'available replicas' as label,
      count(available_replicas) as value
    from
      digitalocean_firewall
    where
      urn = $1
    group by
      label
    union all
    select
      'updated replicas' as label,
      count(updated_replicas) as value
    from
      digitalocean_firewall
    where
      urn = $1
    group by
      label
    union all
    select
      'unavailable replicas' as label,
      count(unavailable_replicas) as value
    from
      digitalocean_firewall
    where
      urn = $1
    group by
      label;
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_replicasets" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      min_ready_seconds as "Min Ready Seconds",
      creation_timestamp as "Create Date"
    from
      kubernetes_replicaset,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_pods" {
  sql = <<-EOQ
    select
      pod.name as "Name",
      pod.uid as "UID",
      pod.restart_policy as "Restart Policy",
      pod.node_name as "Node Name"
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid;
  EOQ

  param "urn" {}
}

query "digitalocean_firewall_tree" {
  sql = <<-EOQ

    -- This deployment
    select
      null as from_id,
      uid as id,
      name as title,
      0 as depth,
      'deployment' as category
    from
      digitalocean_firewall
    where
      urn = $1

    -- replicasets owned by the deployment
    union all
    select
      $1 as from_id,
      uid as id,
      name as title,
      1 as depth,
      'replicaset' as category
    from
      kubernetes_replicaset,
      jsonb_array_elements(owner_references) as owner
    where
      owner ->> 'uid' = $1

    -- Pods owned by the replicasets
    union all
    select
      pod_owner ->> 'uid'  as from_id,
      pod.uid as id,
      pod.name as title,
      2 as depth,
      'pod' as category
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid


    -- containers in Pods owned by the replicasets
    union all
    select
      pod.uid  as from_id,
      concat(pod.uid, '_', container ->> 'name') as id,
      container ->> 'name' as title,
      3 as depth,
      'container' as category
    from
      kubernetes_replicaset as rs,
      jsonb_array_elements(rs.owner_references) as rs_owner,
      kubernetes_pod as pod,
      jsonb_array_elements(pod.owner_references) as pod_owner,
      jsonb_array_elements(pod.containers) as container
    where
      rs_owner ->> 'uid' = $1
      and pod_owner ->> 'uid' = rs.uid


  EOQ


  param "urn" {}

}
