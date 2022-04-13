dashboard "digitalocean_droplet_detail" {

  title         = "DigitalOcean Droplet Detail"
  documentation = file("./dashboards/droplet/docs/droplet_detail.md")

  tags = merge(local.droplet_common_tags, {
    type = "Detail"
  })

  input "droplet_urn" {
    title = "Select a droplet:"
    query = query.digitalocean_droplet_detail_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.digitalocean_droplet_detail_status
      args = {
        urn = self.input.droplet_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_droplet_detail_image
      args = {
        urn = self.input.droplet_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_droplet_detail_disk
      args = {
        urn = self.input.droplet_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_droplet_detail_total_vcpus
      args = {
        urn = self.input.droplet_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_droplet_detail_public_access
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
        query = query.digitalocean_droplet_detail_overview
        args = {
          urn = self.input.droplet_urn.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.digitalocean_droplet_detail_tags
        args = {
          urn = self.input.droplet_urn.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Attached Volumes"
        query = query.digitalocean_droplet_detail_attached_volumes
        args = {
          urn = self.input.droplet_urn.value
        }
        width = 6

        column "Volume URN" {
          display = "none"
        }

        # column "Droplet ID" {
        #   href = "${dashboard.digitalocean_droplet_detail.url_path}?input.droplet_urn={{.'URN' | @uri}}"
        # }
      }

      table {
        title = "Features Enabled"
        query = query.digitalocean_droplet_detail_features_enabled
        args = {
          urn = self.input.droplet_urn.value
        }
        width = 6
      }
    }
  }

  container {

    container {

      width = 6

      table {
        title = "Firewall Configuration"
        query = query.digitalocean_droplet_detail_firewall_configuration
        args = {
          urn = self.input.droplet_urn.value
        }
      }

    }

    container {

      width = 6

      table {
        title = "VPC Details"
        query = query.digitalocean_droplet_detail_vpc_details
        args = {
          urn = self.input.droplet_urn.value
        }
      }
    }

  }

}

query "digitalocean_droplet_detail_input" {
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

query "digitalocean_droplet_detail_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      status as value
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_detail_image" {
  sql = <<-EOQ
    select
      'Distribution Type' as label,
      image ->> 'description' as value
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_detail_disk" {
  sql = <<-EOQ
    select
      'Disk Storage (GB)' as label,
      disk as value
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_detail_total_vcpus" {
  sql = <<-EOQ
    select
      'Total Virtual CPUs' as label,
      vcpus as value
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_detail_public_access" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case
        when image ->> 'public' = 'true' then 'Enabled'
        else 'Disabled'
      end as value,
      case
        when image ->> 'public' != 'true' then 'ok'
        else 'alert'
      end as "type"
    from
      digitalocean_droplet
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_detail_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "Droplet ID",
      created_at as "Created Time",
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

query "digitalocean_droplet_detail_tags" {
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

query "digitalocean_droplet_detail_attached_volumes" {
  sql = <<-EOQ
    select
      v.id as "Volume ID",
      v.name as "Name",
      v.urn as "Volume URN"
    from
      digitalocean_droplet as d,
      jsonb_array_elements_text(d.volume_ids) as volume_id,
      digitalocean_volume as v
    where
      v.id = volume_id
      and d.urn = $1
    order by
      v.id;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_detail_features_enabled" {
  sql = <<-EOQ
    select
      feature as "Features"
    from
      digitalocean_droplet,
      jsonb_array_elements_text(features) as feature
    where
      urn = $1
    order by
      feature;
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_detail_vpc_details" {
  sql = <<-EOQ
    select 
      vpc.id as "VPC ID",
      vpc.name as "VPC Name",
      vpc.ip_range as "IP Range",
      vpc.created_at as "Created Time"
    from
      digitalocean_droplet 
    join 
      digitalocean_vpc vpc 
      on vpc.id = vpc_uuid
  EOQ

  param "urn" {}
}

query "digitalocean_droplet_detail_firewall_configuration" {
  sql = <<-EOQ
    select
      f.id as "Firewall ID", 
      f.name as "Firewall Name",
      f.created_at as "Created Time"
    from
      digitalocean_droplet dr,
      digitalocean_firewall f, 
      jsonb_array_elements(droplet_ids) dr_id 
    where 
      dr.id = dr_id::bigint
      and dr.urn = $1
    order by
      f.id;
  EOQ

  param "urn" {}
}
