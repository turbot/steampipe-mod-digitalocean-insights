dashboard "digitalocean_volume_detail" {

  title         = "DigitalOcean Volume Detail"
  documentation = file("./dashboards/volume/docs/volume_detail.md")

  tags = merge(local.volume_common_tags, {
    type = "Detail"
  })

  input "volume_urn" {
    title = "Select a volume:"
    query = query.digitalocean_volume_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.digitalocean_volume_storage
      args = {
        urn = self.input.volume_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_volume_filesystem_type
      args = {
        urn = self.input.volume_urn.value
      }
    }

    card {
      width = 2
      query = query.digitalocean_volume_attached_droplets_count
      args = {
        urn = self.input.volume_urn.value
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
        query = query.digitalocean_volume_overview
        args = {
          urn = self.input.volume_urn.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.digitalocean_volume_tags
        args = {
          urn = self.input.volume_urn.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Attached To"
        query = query.digitalocean_volume_attached_droplets
        args = {
          urn = self.input.volume_urn.value
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

}

query "digitalocean_volume_input" {
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

query "digitalocean_volume_storage" {
  sql = <<-EOQ
    select
      'Storage (GB)' as label,
      sum(size_gigabytes) as value
    from
      digitalocean_volume
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_volume_filesystem_type" {
  sql = <<-EOQ
    select
      'Filesystem Type' as label,
      filesystem_type as value
    from
      digitalocean_volume
    where
      urn = $1;
  EOQ

  param "urn" {}
}

query "digitalocean_volume_attached_droplets_count" {
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

  param "urn" {}
}

query "digitalocean_volume_overview" {
  sql = <<-EOQ
    select
      id as "Volume ID",
      title as "Title",
      region_name as "Region",
      urn as "URN"
    from
      digitalocean_volume
    where
      urn = $1
  EOQ

  param "urn" {}
}

query "digitalocean_volume_tags" {
  sql = <<-EOQ
    select
      tag ->> 'Key' as "Key",
      tag ->> 'Value' as "Value"
    from
      digitalocean_volume,
      jsonb_array_elements(tags_src) as tag
    where
      urn = $1
    order by
      tag ->> 'Key';
  EOQ

  param "urn" {}
}

query "digitalocean_volume_attached_droplets" {
  sql = <<-EOQ
    select
      d.id as "Droplet ID",
      d.name as "Name",
      d.urn as "Droplet URN",
      d.status as "Instance State"
    from
      digitalocean_volume as v,
      jsonb_array_elements(v.droplet_ids) as droplet_id,
      digitalocean_droplet as d
    where
      d.id = droplet_id::bigint
      and v.urn = $1
    order by
      d.id;
  EOQ

  param "urn" {}
}