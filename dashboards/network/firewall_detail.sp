dashboard "digitalocean_firewall_detail" {

  title         = "DigitalOcean Firewall Detail"
  documentation = file("./dashboards/network/docs/firewall_detail.md")

  tags = merge(local.network_common_tags, {
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
      args = [self.input.firewall_urn.value]
    }

    card {
      width = 2
      query = query.digitalocean_firewall_unrestricted_inbound_rules
      args = [self.input.firewall_urn.value]
    }

    card {
      width = 2
      query = query.digitalocean_firewall_unrestricted_outbound_rules
      args = [self.input.firewall_urn.value]
    }

  }

  with "droplet_droplets_for_network_firewall" {
    query = query.droplet_droplets_for_network_firewall
    args  = [self.input.firewall_urn.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.droplet_droplet
        args = {
          droplet_droplet_urns = with.droplet_droplets_for_network_firewall.rows[*].droplet_urn
        }
      }

      node {
        base = node.network_firewall
        args = {
          network_firewall_urns = [self.input.firewall_urn.value]
        }
      }

      edge {
        base = edge.network_firewall_to_droplet_droplet
        args = {
          network_firewall_urns = [self.input.firewall_urn.value]
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
        query = query.digitalocean_firewall_overview
        args = [self.input.firewall_urn.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.digitalocean_firewall_tags
        args = [self.input.firewall_urn.value]
      }
    }

    container {

      width = 6

      table {
        title = "Attached To"
        query = query.digitalocean_firewall_attached
        args = [self.input.firewall_urn.value]

        column "URN" {
          display = "none"
        }

        column "Droplet Name" {
          href = "${dashboard.droplet_detail.url_path}?input.droplet_urn={{.'URN' | @uri}}"
        }
      }

    }

  }

  container {

    flow {
      title = "Inbound Rules Analysis"
      width = 6
      query = query.digitalocean_firewall_inbound_analysis
      args = [self.input.firewall_urn.value]
    }

    flow {
      title = "Outbound Rules Analysis"
      width = 6
      query = query.digitalocean_firewall_outbound_analysis
      args = [self.input.firewall_urn.value]
    }

  }

}

# Input queries

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

# With queries

query "droplet_droplets_for_network_firewall" {
  sql = <<-EOQ
    with firewall_droplet_ids as (
      select
        jsonb_array_elements(droplet_ids) as did,
        urn
      from
        digitalocean_firewall
    )
    select
      d.urn as droplet_urn
    from
      firewall_droplet_ids as f,
      digitalocean_droplet as d
    where
      d.id::text = did::text
      and f.urn = $1;
  EOQ
}

# Card queries

query "digitalocean_firewall_status" {
  sql = <<-EOQ
    select
      initcap(status) as "Status"
    from
      digitalocean_firewall
    where
      urn = $1;
  EOQ
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
}

query "digitalocean_firewall_overview" {
  sql = <<-EOQ
    select
      title as "Title",
      id as "ID",
      created_at as "Create Time",
      urn as "URN"
    from
      digitalocean_firewall
    where
      urn = $1;
  EOQ
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
}

query "digitalocean_firewall_attached" {
  sql = <<-EOQ
    select
      name as "Droplet Name",
      id as "Droplet ID",
      created_at as "Create Time",
      urn as "URN"
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
      urn = $1)
    order by
      name;
  EOQ
}

query "digitalocean_firewall_inbound_analysis" {
  sql = <<-EOQ
    with rules as (
      select
        urn,
        title,
        id,
        i ->> 'protocol' as protocol_number,
        cidr as cidr_block,
        i ->> 'ports' as ports,
        case
          when i->>'protocol' = 'icmp' and i ->> 'ports' = '0' then 'All ICMP'
          when i->>'protocol' = 'tcp' and i ->> 'ports' = '0' then 'All TCP'
          when i->>'protocol' = 'udp' and i ->> 'ports' = '0' then 'All UDP'
          when i->>'protocol' = 'tcp' and i ->> 'ports' <> '0' then concat(i ->> 'ports', '/TCP')
          when i->>'protocol' = 'udp' and i ->> 'ports' <> '0' then concat(i ->> 'ports', '/UDP')
            else concat('Procotol: ', i->>'protocol')
        end as rule_description
      from
        digitalocean_firewall,
        jsonb_array_elements(inbound_rules) as i,
        jsonb_array_elements_text(i -> 'sources' -> 'addresses') as cidr
      where
        urn = $1
    )

    -- CIDR Nodes
    select
      distinct cidr_block as id,
      cidr_block as title,
      'cidr_block' as category,
      null as from_id,
      null as to_id
    from rules

    -- Rule Nodes
    union select
      concat(title,'_',rule_description) as id,
      rule_description as title,
      'rule' as category,
      null as from_id,
      null as to_id
    from rules

    -- Firewall Nodes
    union select
      distinct title as id,
      title as title,
      'inbound' as category,
      null as from_id,
      null as to_id
    from rules

    -- ip -> rule edge
    union select
      null as id,
      null as title,
      protocol_number as category,
      cidr_block as from_id,
      concat(title,'_',rule_description) as to_id
    from rules

    -- rule -> Firewall edge
    union select
      null as id,
      null as title,
      protocol_number as category,
      concat(title,'_',rule_description) as from_id,
      title as to_id
    from rules
  EOQ
}

query "digitalocean_firewall_outbound_analysis" {
  sql = <<-EOQ
    with rules as (
      select
        urn,
        title,
        id,
        r ->> 'protocol' as protocol_number,
        cidr as cidr_block,
        r ->> 'ports' as ports,
        case
          when r->>'protocol' = 'icmp' and r ->> 'ports' = '0' then 'All ICMP'
          when r->>'protocol' = 'tcp' and r ->> 'ports' = '0' then 'All TCP'
          when r->>'protocol' = 'udp' and r ->> 'ports' = '0' then 'All UDP'
          when r->>'protocol' = 'tcp' and r ->> 'ports' <> '0' then concat(r ->> 'ports', '/TCP')
          when r->>'protocol' = 'udp' and r ->> 'ports' <> '0' then concat(r ->> 'ports', '/UDP')
            else concat('Procotol: ', r->>'protocol')
        end as rule_description
      from
        digitalocean_firewall,
        jsonb_array_elements(outbound_rules) as r,
        jsonb_array_elements_text(r -> 'destinations' -> 'addresses') as cidr
      where
        urn = $1
    )

    select
      distinct title as id,
      title as title,
      'inbound' as category,
      null as from_id,
      null as to_id,
      0 as depth
    from rules

    -- Rule Nodes
    union select
      concat(title,'_',rule_description) as id,
      rule_description as title,
      'rule' as category,
      null as from_id,
      null as to_id,
      1 as depth
    from rules

    -- CIDR Nodes
    union select
      distinct cidr_block as id,
      cidr_block as title,
      'cidr_block' as category,
      null as from_id,
      null as to_id,
      2 as depth
    from rules

    -- rule -> Firewall edge
    union select
      null as id,
      null as title,
      protocol_number as category,
      concat(title,'_',rule_description) as from_id,
      title as to_id,
      null as depth
    from rules

    -- ip -> rule edge
    union select
      null as id,
      null as title,
      protocol_number as category,
      cidr_block as from_id,
      concat(title,'_',rule_description) as from_id,
      null as depth
    from rules

  EOQ
}


