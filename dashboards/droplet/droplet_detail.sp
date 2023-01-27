dashboard "droplet_detail" {

  title         = "DigitalOcean Droplet Detail"
  documentation = file("./dashboards/droplet/docs/droplet_detail.md")

  tags = merge(local.droplet_common_tags, {
    type = "Detail"
  })

  input "droplet_urn" {
    title = "Select a droplet:"
    query = query.droplet_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.droplet_status
      args  = [self.input.droplet_urn.value]
    }

    card {
      width = 2
      query = query.droplet_vcpus
      args  = [self.input.droplet_urn.value]
    }

    card {
      width = 2
      query = query.droplet_storage
      args  = [self.input.droplet_urn.value]
    }

    card {
      width = 2
      query = query.droplet_public_access
      args  = [self.input.droplet_urn.value]
    }

    card {
      width = 2
      query = query.droplet_backup_status
      args  = [self.input.droplet_urn.value]
    }

    card {
      width = 2
      query = query.droplet_monitoring_status
      args  = [self.input.droplet_urn.value]
    }

  }

  with "blockstorage_volumes_for_droplet" {
    query = query.blockstorage_volumes_for_droplet
    args  = [self.input.droplet_urn.value]
  }

  with "image_images_for_droplet" {
    query = query.image_images_for_droplet
    args  = [self.input.droplet_urn.value]
  }

  with "network_firewalls_for_droplet" {
    query = query.network_firewalls_for_droplet
    args  = [self.input.droplet_urn.value]
  }

  with "network_floating_ips_for_droplet" {
    query = query.network_floating_ips_for_droplet
    args  = [self.input.droplet_urn.value]
  }

  with "network_load_balancers_for_droplet" {
    query = query.network_load_balancers_for_droplet
    args  = [self.input.droplet_urn.value]
  }

  with "network_vpcs_for_droplet" {
    query = query.network_vpcs_for_droplet
    args  = [self.input.droplet_urn.value]
  }

  with "snapshot_snapshots_for_droplet" {
    query = query.snapshot_snapshots_for_droplet
    args  = [self.input.droplet_urn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.blockstorage_volume
        args = {
          blockstorage_volume_urns = with.blockstorage_volumes_for_droplet.rows[*].volume_urn
        }
      }

      node {
        base = node.droplet_droplet
        args = {
          droplet_droplet_urns = [self.input.droplet_urn.value]
        }
      }

      node {
        base = node.image_image
        args = {
          image_image_urns = with.image_images_for_droplet.rows[*].image_urn
        }
      }

      node {
        base = node.network_firewall
        args = {
          network_firewall_urns = with.network_firewalls_for_droplet.rows[*].firewall_urn
        }
      }

      node {
        base = node.network_floating_ip
        args = {
          network_floating_ip_urns = with.network_floating_ips_for_droplet.rows[*].floating_ip_urn
        }
      }

      node {
        base = node.network_load_balancer
        args = {
          network_load_balancer_urns = with.network_load_balancers_for_droplet.rows[*].lb_urn
        }
      }

      node {
        base = node.network_vpc
        args = {
          network_vpc_urns = with.network_vpcs_for_droplet.rows[*].vpc_urn
        }
      }

      node {
        base = node.snapshot_snapshot
        args = {
          snapshot_snapshot_urns = with.snapshot_snapshots_for_droplet.rows[*].snapshot_urn
        }
      }

      edge {
        base = edge.droplet_droplet_to_blockstorage_volume
        args = {
          droplet_droplet_urns = [self.input.droplet_urn.value]
        }
      }

      edge {
        base = edge.droplet_droplet_to_network_firewall
        args = {
          droplet_droplet_urns = [self.input.droplet_urn.value]
        }
      }

      edge {
        base = edge.droplet_droplet_to_network_floating_ip
        args = {
          droplet_droplet_urns = [self.input.droplet_urn.value]
        }
      }

      edge {
        base = edge.droplet_droplet_to_network_load_balancer
        args = {
          droplet_droplet_urns = [self.input.droplet_urn.value]
        }
      }

      edge {
        base = edge.droplet_droplet_to_network_vpc
        args = {
          droplet_droplet_urns = [self.input.droplet_urn.value]
        }
      }

      edge {
        base = edge.network_firewall_to_network_vpc
        args = {
          droplet_droplet_urns = [self.input.droplet_urn.value]
        }
      }

      edge {
        base = edge.droplet_droplet_to_snapshot_snapshot
        args = {
          droplet_droplet_urns = [self.input.droplet_urn.value]
        }
      }

      edge {
        base = edge.image_image_to_droplet_droplet
        args = {
          image_image_urns = with.image_images_for_droplet.rows[*].image_urn
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
        query = query.droplet_overview
        args  = [self.input.droplet_urn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.droplet_tags
        args  = [self.input.droplet_urn.value]
      }
    }

    container {

      width = 6

      table {
        title = "Attached Volumes"
        query = query.droplet_attached_volumes
        args  = [self.input.droplet_urn.value]

        column "Volume URN" {
          display = "none"
        }

        column "Volume Name" {
          href = "/digitalocean_insights.dashboard.blockstorage_volume_detail?input.volume_urn={{.'Volume URN' | @uri}}"
        }
      }

    }
  }

  container {

    container {

      width = 6

      table {
        title = "Firewall Details"
        query = query.droplet_firewall_configuration
        args  = [self.input.droplet_urn.value]

        column "URN" {
          display = "none"
        }

        column "Name" {
          href = "/digitalocean_insights.dashboard.network_firewall_detail?input.firewall_urn={{.'URN' | @uri}}"
        }
      }

    }

    container {

      width = 6

      table {
        title = "VPC Details"
        query = query.droplet_network_vpc_details
        args  = [self.input.droplet_urn.value]

        column "URN" {
          display = "none"
        }

        column "Name" {
          href = "/digitalocean_insights.dashboard.network_vpc_detail?input.vpc_urn={{.'URN' | @uri}}"
        }
      }
    }

  }

}

# Input queries

query "droplet_input" {
  sql = <<-EOQ
    select
      title as label,
      urn as value,
      json_build_object(
        'region', region_slug,
        'id', id
      ) as tags
    from
      digitalocean_droplet
    order by
      title;
  EOQ
}

# With queries

query "blockstorage_volumes_for_droplet" {
  sql = <<-EOQ
    select
      v.urn as volume_urn
    from
      digitalocean_droplet as d,
      digitalocean_volume as v,
      jsonb_array_elements(droplet_ids) as did
    where
      d.id::int = did::int
      and d.urn = $1;
  EOQ
}

query "image_images_for_droplet" {
  sql = <<-EOQ
    select
      i.urn as image_urn
    from
      digitalocean_image as i,
      digitalocean_droplet as d
    where
      i.id::text = image->>'id'
      and d.urn = $1;
  EOQ
}

query "network_firewalls_for_droplet" {
  sql = <<-EOQ
    select
      f.urn as firewall_urn
    from
      digitalocean_droplet as d,
      digitalocean_firewall as f,
      jsonb_array_elements(droplet_ids) as did
    where
      d.id::text = did::text
      and d.urn = $1;
  EOQ
}

query "network_floating_ips_for_droplet" {
  sql = <<-EOQ
    select
      f.urn as floating_ip_urn
    from
      digitalocean_floating_ip as f,
      digitalocean_droplet as d
    where
      d.id = f.droplet_id
      and d.urn = $1;
  EOQ
}

query "network_load_balancers_for_droplet" {
  sql = <<-EOQ
    select
      l.urn as lb_urn
    from
      digitalocean_droplet as d,
      digitalocean_load_balancer as l,
      jsonb_array_elements(droplet_ids) as did
    where
      d.id::text = did::text
      and d.urn = $1;
  EOQ
}

query "network_vpcs_for_droplet" {
  sql = <<-EOQ
    select
      v.urn as vpc_urn
    from
      digitalocean_vpc as v,
      digitalocean_droplet as d
    where
      d.vpc_uuid = v.id
      and d.urn = $1;
  EOQ
}

query "snapshot_snapshots_for_droplet" {
  sql = <<-EOQ
    select
      s.id as snapshot_urn
    from
      digitalocean_droplet as d,
      jsonb_array_elements(snapshot_ids) as sid,
      digitalocean_snapshot as s
    where
      s.id = sid::text
      and d.urn = $1;
  EOQ
}

# Card queries

query "droplet_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      initcap(status) as value
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ
}

query "droplet_storage" {
  sql = <<-EOQ
    select
      disk as "Disk Storage (GB)"
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ
}

query "droplet_vcpus" {
  sql = <<-EOQ
    select
      'vCPUs' as label,
      vcpus as value
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ
}

query "droplet_public_access" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case
        when image ->> 'public' = 'true' then 'Enabled'
        else 'Disabled'
      end as value,
      case
        when image ->> 'public' = 'true' then 'alert'
        else 'ok'
      end as "type"
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ
}

query "droplet_backup_status" {
  sql = <<-EOQ
    select
      'Backups' as label,
      case
        when features ? 'backups' then 'Enabled'
        else 'Disabled'
      end as value,
      case
        when features ? 'backups' then 'ok'
        else 'alert'
      end as "type"
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ
}

query "droplet_monitoring_status" {
  sql = <<-EOQ
    select
      'Monitoring' as label,
      case
        when features ? 'monitoring' then 'Enabled'
        else 'Disabled'
      end as value,
      case
        when features ? 'monitoring' then 'ok'
        else 'alert'
      end as "type"
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ
}

# Other detail page queries

query "droplet_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      created_at as "Create Time",
      image ->> 'distribution' as "Distribution Type",
      title as "Title",
      region ->> 'name' as "Region",
      urn as "URN"
    from
      digitalocean_droplet
    where
      urn = $1
  EOQ
}

query "droplet_tags" {
  sql = <<-EOQ
    select
      tag.key as "Key",
      tag.value as "Value"
    from
      digitalocean_droplet
      join jsonb_each_text(tags) tag on true
    where
      urn = $1
    order by
      tag.key;
  EOQ
}

query "droplet_attached_volumes" {
  sql = <<-EOQ
    select
      v.name as "Name",
      v.id as "ID",
      v.created_at as "Create Time",
      v.urn as "URN"
    from
      digitalocean_droplet as d,
      jsonb_array_elements_text(d.volume_ids) as volume_id,
      digitalocean_volume as v
    where
      v.id = volume_id
      and d.urn = $1
    order by
      v.name;
  EOQ
}

query "droplet_network_vpc_details" {
  sql = <<-EOQ
    select
      vpc.name as "Name",
      vpc.urn as "URN",
      vpc.id as "ID",
      vpc.ip_range as "IP Range",
      vpc.created_at as "Create Time"
    from
      digitalocean_droplet dr
    join
      digitalocean_vpc vpc
      on vpc.id = vpc_uuid
    where
      dr.urn = $1
    order by
      vpc.name;
  EOQ
}

query "droplet_firewall_configuration" {
  sql = <<-EOQ
    select
      f.name as "Name",
      f.id as "ID",
      f.created_at as "Create Time",
      f.urn as "URN"
    from
      digitalocean_droplet dr,
      digitalocean_firewall f,
      jsonb_array_elements(droplet_ids) dr_id
    where
      dr.id = dr_id::bigint
      and dr.urn = $1
    order by
      f.name;
  EOQ
}
