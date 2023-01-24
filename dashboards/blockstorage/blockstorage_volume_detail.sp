dashboard "blockstorage_volume_detail" {

  title         = "DigitalOcean Block Storage Volume Detail"
  documentation = file("./dashboards/blockstorage/docs/blockstorage_volume_detail.md")

  tags = merge(local.blockstorage_volume_common_tags, {
    type = "Detail"
  })

  input "volume_urn" {
    title = "Select a volume:"
    query = query.blockstorage_volume_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.blockstorage_volume_storage
      args  = [self.input.volume_urn.value]
    }

    card {
      width = 2
      query = query.blockstorage_volume_filesystem_type
      args  = [self.input.volume_urn.value]
    }

    card {
      width = 2
      query = query.blockstorage_volume_attached_droplets_count
      args  = [self.input.volume_urn.value]
    }
  }

  with "droplet_droplets_for_blockstorage_volume" {
    query = query.droplet_droplets_for_blockstorage_volume
    args  = [self.input.volume_urn.value]
  }

  with "network_floating_ips_for_blockstorage_volume" {
    query = query.network_floating_ips_for_blockstorage_volume
    args  = [self.input.volume_urn.value]
  }

  with "target_snapshot_snapshots_for_blockstorage_volume" {
    query = query.target_snapshot_snapshots_for_blockstorage_volume
    args  = [self.input.volume_urn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.blockstorage_volume
        args = {
          blockstorage_volume_urns = [self.input.volume_urn.value]
        }
      }

      node {
        base = node.droplet_droplet
        args = {
          droplet_droplet_urns = with.droplet_droplets_for_blockstorage_volume.rows[*].droplet_urn
        }
      }

      node {
        base = node.network_floating_ip
        args = {
          network_floating_ip_urns = with.network_floating_ips_for_blockstorage_volume.rows[*].floating_ip_urn
        }
      }

      node {
        base = node.snapshot_snapshot
        args = {
          snapshot_snapshot_urns = with.target_snapshot_snapshots_for_blockstorage_volume.rows[*].snapshot_urn
        }
      }

      edge {
        base = edge.blockstorage_volume_to_snapshot_snapshot
        args = {
          blockstorage_volume_urns = [self.input.volume_urn.value]
        }
      }

      edge {
        base = edge.blockstorage_volume_to_network_floating_ip
        args = {
          blockstorage_volume_urns = [self.input.volume_urn.value]
        }
      }

      edge {
        base = edge.droplet_droplet_to_blockstorage_volume
        args = {
          droplet_droplet_urns = with.droplet_droplets_for_blockstorage_volume.rows[*].droplet_urn
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
        query = query.blockstorage_volume_overview
        args  = [self.input.volume_urn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.blockstorage_volume_tags
        args  = [self.input.volume_urn.value]
      }
    }

    container {

      width = 6

      table {
        title = "Attached Droplet"
        query = query.blockstorage_volume_attached_droplets
        args  = [self.input.volume_urn.value]

        column "Droplet URN" {
          display = "none"
        }

        column "Droplet Name" {
          href = "/digitalocean_insights.dashboard.droplet_detail?input.droplet_urn={{.'Droplet URN' | @uri}}"
        }
      }
    }
  }

}

# Input queries

query "blockstorage_volume_input" {
  sql = <<-EOQ
    select
      title as label,
      urn as value,
      json_build_object(
        'region', region_slug,
        'id', id
      ) as tags
    from
      digitalocean_volume
    order by
      title;
  EOQ
}

# With queries

query "droplet_droplets_for_blockstorage_volume" {
  sql = <<-EOQ
    select
      d.urn as droplet_urn
    from
      digitalocean_volume as v,
      jsonb_array_elements(v.droplet_ids) as droplet_id,
      digitalocean_droplet as d
    where
      d.id = droplet_id::bigint
      and v.urn = $1;
  EOQ
}

query "network_floating_ips_for_blockstorage_volume" {
  sql = <<-EOQ
    select
      f.urn as floating_ip_urn
    from
      digitalocean_floating_ip as f,
      jsonb_array_elements_text(droplet -> 'volume_ids') as vid,
      digitalocean_volume as v
    where
      v.id = vid
      and v.urn = $1;
  EOQ
}

query "target_snapshot_snapshots_for_blockstorage_volume" {
  sql = <<-EOQ
    select
      s.id as snapshot_urn
    from
      digitalocean_volume as v,
      digitalocean_snapshot as s
    where
      s.resource_id = v.id
      and s.resource_type = 'volume'
      and v.urn = $1;
  EOQ
}

# Card queries

query "blockstorage_volume_attached_droplets_count" {
  sql = <<-EOQ
    select
      'Attached Droplets' as label,
      case
        when droplet_ids is null then 0
        else jsonb_array_length(droplet_ids)
      end as value,
      case
        when jsonb_array_length(droplet_ids) > 0 then 'ok'
        else 'alert'
      end as "type"
    from
      digitalocean_volume
    where
      urn = $1;
  EOQ
}

query "blockstorage_volume_filesystem_type" {
  sql = <<-EOQ
    select
      'Filesystem Type' as label,
      filesystem_type as value
    from
      digitalocean_volume
    where
      urn = $1;
  EOQ
}

query "blockstorage_volume_storage" {
  sql = <<-EOQ
    select
      'Storage (GB)' as label,
      sum(size_gigabytes) as value
    from
      digitalocean_volume
    where
      urn = $1;
  EOQ
}

# Other detail page queries

query "blockstorage_volume_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      created_at as "Create Time",
      title as "Title",
      region_name as "Region",
      urn as "URN"
    from
      digitalocean_volume
    where
      urn = $1
  EOQ
}

query "blockstorage_volume_tags" {
  sql = <<-EOQ
    select
      tag.key as "Key",
      tag.value as "Value"
    from
      digitalocean_volume
      join jsonb_each_text(tags) tag on true
    where
      urn = $1
    order by
      tag.key;
  EOQ
}

query "blockstorage_volume_attached_droplets" {
  sql = <<-EOQ
    select
      d.name as "Droplet Name",
      d.id as "Droplet ID",
      d.created_at as "Create Time",
      d.urn as "Droplet URN",
      d.status as "Droplet Status"
    from
      digitalocean_volume as v,
      jsonb_array_elements(v.droplet_ids) as droplet_id,
      digitalocean_droplet as d
    where
      d.id = droplet_id::bigint
      and v.urn = $1
    order by
      d.name;
  EOQ
}
