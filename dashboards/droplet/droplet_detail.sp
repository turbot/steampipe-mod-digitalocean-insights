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

  with "blockstorage_volumes" {
    query = query.droplet_blockstorage_volumes
    args  = [self.input.droplet_urn.value]
  }

  with "from_image_images" {
    query = query.droplet_from_image_images
    args  = [self.input.droplet_urn.value]
  }

  with "network_firewalls" {
    query = query.droplet_network_firewalls
    args  = [self.input.droplet_urn.value]
  }

  with "network_floating_ips" {
    query = query.droplet_network_floating_ips
    args  = [self.input.droplet_urn.value]
  }

  with "network_load_balancers" {
    query = query.droplet_network_load_balancers
    args  = [self.input.droplet_urn.value]
  }

  with "network_vpcs" {
    query = query.droplet_network_vpcs
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
          blockstorage_volume_urns = with.blockstorage_volumes.rows[*].volume_urn
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
          image_image_urns = with.from_image_images.rows[*].image_urn
        }
      }

      node {
        base = node.network_firewall
        args = {
          network_firewall_urns = with.network_firewalls.rows[*].firewall_urn
        }
      }

      node {
        base = node.network_floating_ip
        args = {
          network_floating_ip_urns = with.network_floating_ips.rows[*].floating_ip_urn
        }
      }

      node {
        base = node.network_load_balancer
        args = {
          network_load_balancer_urns = with.network_load_balancers.rows[*].lb_urn
        }
      }

      node {
        base = node.network_vpc
        args = {
          network_vpc_urns = with.network_vpcs.rows[*].vpc_urn
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
        base = edge.image_image_to_droplet_droplet
        args = {
          image_image_urns = with.from_image_images.rows[*].image_urn
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
          href = "${dashboard.digitalocean_blockstorage_volume_detail.url_path}?input.volume_urn={{.'Volume URN' | @uri}}"
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

          # href = "${dashboard.digitalocean_droplet_detail.url_path}?input.droplet_urn={{.'Droplet URN' | @uri}}"
          // cyclic dependency prevents use of url_path, hardcode for now
          href = "/digitalocean_insights.dashboard.digitalocean_firewall_detail?input.firewall_urn={{.'URN' | @uri}}"
        }
      }

    }

    container {

      width = 6

      table {
        title = "VPC Details"
        query = query.droplet_vpc_details
        args  = [self.input.droplet_urn.value]
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

query "droplet_blockstorage_volumes" {
  sql = <<-EOQ
    with volume_droplet_ids as (
      select
        jsonb_array_elements(droplet_ids) as d,
        urn
      from
        digitalocean_volume
    )
    select
      v.urn as volume_urn
    from
      digitalocean_droplet as d,
      volume_droplet_ids as v
    where
      d.id::int = d::int
      and d.urn = $1;
  EOQ
}

query "droplet_from_image_images" {
  sql = <<-EOQ
    with droplet_images as (
      select
        image->>'id' as iid,
        urn
      from
        digitalocean_droplet
    )
    select
      i.urn as image_urn
    from
      digitalocean_image as i,
      droplet_images as d
    where
      i.public = true
      and i.id::text = iid
      and d.urn = $1;
  EOQ
}

query "droplet_network_firewalls" {
  sql = <<-EOQ
    with firewall_droplet_ids as (
      select
        jsonb_array_elements(droplet_ids) as did,
        urn
      from
        digitalocean_firewall
    )
    select
      f.urn as firewall_urn
    from
      firewall_droplet_ids as f,
      digitalocean_droplet as d
    where
      d.id::text = did::text
      and d.urn = $1;
  EOQ
}

query "droplet_network_floating_ips" {
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

query "droplet_network_load_balancers" {
  sql = <<-EOQ
    with lb_droplet_ids as (
      select
        jsonb_array_elements(droplet_ids) as did,
        urn
      from
        digitalocean_load_balancer
    )
    select
      l.urn as lb_urn
    from
      lb_droplet_ids as l,
      digitalocean_droplet as d
    where
      d.id::text = did::text
      and d.urn = $1;
  EOQ
}

query "droplet_network_vpcs" {
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
      id as "Droplet ID",
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

query "droplet_vpc_details" {
  sql = <<-EOQ
    select
      vpc.name as "Name",
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
