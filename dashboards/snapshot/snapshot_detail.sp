dashboard "snapshot_detail" {

  title         = "DigitalOcean Snapshot Detail"
  documentation = file("./dashboards/snapshot/docs/snapshot_detail.md")

  tags = merge(local.snapshot_common_tags, {
    type = "Detail"
  })

  input "snapshot_urn" {
    title = "Select a snapshot:"
    query = query.snapshot_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.snapshot_resource_type
      args  = [self.input.snapshot_urn.value]
    }

    card {
      width = 2
      query = query.snapshot_size
      args  = [self.input.snapshot_urn.value]
    }

    card {
      width = 2
      query = query.snapshot_minimum_disk_size
      args  = [self.input.snapshot_urn.value]
    }

    card {
      width = 2
      query = query.snapshot_age
      args  = [self.input.snapshot_urn.value]
    }
  }

  with "network_floating_ips_for_snapshot_snapshot" {
    query = query.network_floating_ips_for_snapshot_snapshot
    args  = [self.input.snapshot_urn.value]
  }

  with "source_droplet_droplets_for_snapshot_snapshot" {
    query = query.source_droplet_droplets_for_snapshot_snapshot
    args  = [self.input.snapshot_urn.value]
  }

  with "source_blockstorage_volumes_for_snapshot_snapshot" {
    query = query.source_blockstorage_volumes_for_snapshot_snapshot
    args  = [self.input.snapshot_urn.value]
  }

  with "target_droplet_droplets_for_snapshot_snapshot" {
    query = query.target_droplet_droplets_for_snapshot_snapshot
    args  = [self.input.snapshot_urn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.blockstorage_volume
        args = {
          blockstorage_volume_urns = with.source_blockstorage_volumes_for_snapshot_snapshot.rows[*].source_volume_urn
        }
      }

      node {
        base = node.droplet_droplet
        args = {
          droplet_droplet_urns = with.source_droplet_droplets_for_snapshot_snapshot.rows[*].source_droplet_urn
        }
      }

      node {
        base = node.droplet_droplet
        args = {
          droplet_droplet_urns = with.target_droplet_droplets_for_snapshot_snapshot.rows[*].target_droplet_urn
        }
      }

      node {
        base = node.network_floating_ip
        args = {
          network_floating_ip_urns = with.network_floating_ips_for_snapshot_snapshot.rows[*].floating_ip_urn
        }
      }

      node {
        base = node.snapshot_snapshot
        args = {
          snapshot_snapshot_urns = [self.input.snapshot_urn.value]
        }
      }

      edge {
        base = edge.droplet_droplet_to_snapshot_snapshot
        args = {
          droplet_droplet_urns = with.source_droplet_droplets_for_snapshot_snapshot.rows[*].source_droplet_urn
        }
      }

      edge {
        base = edge.snapshot_snapshot_to_droplet_droplet
        args = {
          snapshot_snapshot_urns = [self.input.snapshot_urn.value]
        }
      }

      edge {
        base = edge.blockstorage_volume_to_snapshot_snapshot
        args = {
          blockstorage_volume_urns = with.source_blockstorage_volumes_for_snapshot_snapshot.rows[*].source_volume_urn
        }
      }

      edge {
        base = edge.snapshot_snapshot_to_network_floating_ip
        args = {
          snapshot_snapshot_urns = [self.input.snapshot_urn.value]
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
        query = query.snapshot_overview
        args  = [self.input.snapshot_urn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.snapshot_tags
        args  = [self.input.snapshot_urn.value]
      }
    }

    container {

      width = 6

      table {
        title = "Source Droplet"
        query = query.snapshot_source_droplet
        args  = [self.input.snapshot_urn.value]

        column "Droplet URN" {
          display = "none"
        }

        column "Droplet Name" {
          href = "/digitalocean_insights.dashboard.droplet_detail?input.droplet_urn={{.'Droplet URN' | @uri}}"
        }
      }

      table {
        title = "Source Volume"
        query = query.snapshot_source_blockstorage_volume
        args  = [self.input.snapshot_urn.value]

        column "Volume URN" {
          display = "none"
        }

        column "Volume Name" {
          href = "/digitalocean_insights.dashboard.blockstorage_volume_detail?input.volume_urn={{.'Volume URN' | @uri}}"
        }
      }
    }
  }
}


# Input queries

query "snapshot_input" {
  sql = <<-EOQ
    select
      title as label,
      id as value,
      json_build_object(
        'id', id
      ) as tags
    from
      digitalocean_snapshot
    order by
      title;
  EOQ
}

# With queries

query "network_floating_ips_for_snapshot_snapshot" {
  sql = <<-EOQ
    select
      f.urn as floating_ip_urn
    from
      digitalocean_floating_ip as f,
      jsonb_array_elements(droplet -> 'snapshot_ids') as sid,
      digitalocean_snapshot as s
    where
      s.id = sid::text
      and s.id = $1;
  EOQ
}

query "source_droplet_droplets_for_snapshot_snapshot" {
  sql = <<-EOQ
    select
      d.urn as source_droplet_urn
    from
      digitalocean_droplet as d,
      jsonb_array_elements(snapshot_ids) as sid,
      digitalocean_snapshot as s
    where
      s.id = sid::text
      and s.id = $1;
  EOQ
}

query "target_droplet_droplets_for_snapshot_snapshot" {
  sql = <<-EOQ
    with droplet_images as (
      select
        image->>'id' as iid,
        urn
      from
        digitalocean_droplet
    )
    select
      d.urn as target_droplet_urn
    from
      digitalocean_image as i,
      digitalocean_snapshot as s,
      droplet_images as d
    where
      i.id::text = iid
      and i.id::text = s.id
      and s.id = $1;
  EOQ
}

query "source_blockstorage_volumes_for_snapshot_snapshot" {
  sql = <<-EOQ
    select
      v.urn as source_volume_urn
    from
      digitalocean_volume as v,
      digitalocean_snapshot as s
    where
      s.resource_id = v.id
      and s.resource_type = 'volume'
      and s.id = $1;
  EOQ
}

# Card queries

query "snapshot_resource_type" {
  sql = <<-EOQ
    select
      'Source Resource' as label,
      initcap(resource_type) as value
    from
      digitalocean_snapshot
    where
      id = $1;
  EOQ
}

query "snapshot_size" {
  sql = <<-EOQ
    select
      'Size (GB)' as label,
      sum(size_gigabytes) as value
    from
      digitalocean_snapshot
    where
      id = $1;
  EOQ
}

query "snapshot_minimum_disk_size" {
  sql = <<-EOQ
    select
      'Minimum disk size (GB)' as label,
      min_disk_size as value
    from
      digitalocean_snapshot
    where
      id = $1;
  EOQ
}

query "snapshot_age" {
  sql = <<-EOQ
    with data as (
      select
        (extract(epoch from (select (now() - created_at)))/86400)::int as age
      from
        digitalocean_snapshot
      where
        id = $1
    )
    select
      'Age (in Days)' as label,
      age as value,
      case when age<35 then 'ok' else 'alert' end as type
    from
      data;
  EOQ
}

# Other detail page queries

query "snapshot_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      created_at as "Create Time",
      title as "Title",
      regions as "Regions"
    from
      digitalocean_snapshot
    where
      id = $1
  EOQ
}

query "snapshot_tags" {
  sql = <<-EOQ
    select
      tag.key as "Key",
      tag.value as "Value"
    from
      digitalocean_snapshot
      join jsonb_each_text(tags) tag on true
    where
      id = $1
    order by
      tag.key;
  EOQ
}

query "snapshot_source_droplet" {
  sql = <<-EOQ
    select
      d.urn as "Droplet URN",
      d.name as "Droplet Name",
      d.id as "Droplet ID",
      d.status as "Droplet Status"
    from
      digitalocean_droplet as d,
      jsonb_array_elements(snapshot_ids) as sid,
      digitalocean_snapshot as s
    where
      s.id = sid::text
      and s.id = $1;
  EOQ
}

query "snapshot_source_blockstorage_volume" {
  sql = <<-EOQ
    select
      v.urn as "Volume URN",
      v.name as "Volume Name",
      v.id as "Volume ID",
      v.size_gigabytes as "Volume Size (GB)"
    from
      digitalocean_volume as v,
      digitalocean_snapshot as s
    where
      s.resource_id = v.id
      and s.resource_type = 'volume'
      and s.id = $1;
  EOQ
}

