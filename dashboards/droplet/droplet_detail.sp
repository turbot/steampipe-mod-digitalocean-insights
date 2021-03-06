dashboard "digitalocean_droplet_detail" {

  title         = "DigitalOcean Droplet Detail"
  documentation = file("./dashboards/droplet/docs/droplet_detail.md")

  tags = merge(local.droplet_common_tags, {
    type = "Detail"
  })

  input "droplet_urn" {
    title = "Select a droplet:"
    query = query.digitalocean_droplet_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.digitalocean_droplet_status
      args = {
        urn = self.input.droplet_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_droplet_vcpus
      args = {
        urn = self.input.droplet_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_droplet_storage
      args = {
        urn = self.input.droplet_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_droplet_public_access
      args = {
        urn = self.input.droplet_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_droplet_backup_status
      args = {
        urn = self.input.droplet_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_droplet_monitoring_status
      args = {
        urn = self.input.droplet_urn.value
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
        query = query.digitalocean_droplet_overview
        args = {
          urn = self.input.droplet_urn.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.digitalocean_droplet_tags
        args = {
          urn = self.input.droplet_urn.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Attached Volumes"
        query = query.digitalocean_droplet_attached_volumes
        args = {
          urn = self.input.droplet_urn.value
        }

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
        query = query.digitalocean_droplet_firewall_configuration
        args = {
          urn = self.input.droplet_urn.value
        }

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
        query = query.digitalocean_droplet_vpc_details
        args = {
          urn = self.input.droplet_urn.value
        }
      }
    }

  }

}

query "digitalocean_droplet_input" {
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

query "digitalocean_droplet_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      initcap(status) as value
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_storage" {
  sql = <<-EOQ
    select
      disk as "Disk Storage (GB)"
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_vcpus" {
  sql = <<-EOQ
    select
      'vCPUs' as label,
      vcpus as value
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_public_access" {
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

  param "urn" {}
}

query "digitalocean_droplet_backup_status" {
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

  param "urn" {}
}

query "digitalocean_droplet_monitoring_status" {
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

  param "urn" {}
}

query "digitalocean_droplet_overview" {
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

  param "urn" {}
}

query "digitalocean_droplet_tags" {
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

  param "urn" {}
}

query "digitalocean_droplet_attached_volumes" {
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

  param "urn" {}
}

query "digitalocean_droplet_vpc_details" {
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

  param "urn" {}
}

query "digitalocean_droplet_firewall_configuration" {
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

  param "urn" {}
}
